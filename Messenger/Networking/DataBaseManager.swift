//
//  DataBaseManager.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

final class DataBaseManager {
  static let shared = DataBaseManager()
  
  private let database = Database.database().reference()
  
  static func safeEmail(email: String) -> String {
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
}

extension DataBaseManager {
  
  public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
    database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      completion(.success(value))
    }
  }
}


extension DataBaseManager {
  public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
    
    let safeEmail = DataBaseManager.safeEmail(email: email)
    
    database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
      guard snapshot.value as? [String: Any] != nil else {
        completion(false)
        return
      }
      completion(true)
    }
  }
  
  public func insertUser(with user: MessengerModel, completion: @escaping (Bool) -> Void) {
    database.child(user.safeEmail).setValue([
      "first_name": user.firstName,
      "last_name": user.lastName
    ]) { [weak self] error, _ in
      guard error == nil else {
        print("Failed to write to database")
        completion(false)
        return
      }
      
      self?.database.child("users").observeSingleEvent(of: .value) { [weak self] snapShot in
        if var usersCollection = snapShot.value as? [[String: String]] {
          
          let newElement = [
              "name": user.firstName + " " + user.lastName,
              "email": user.safeEmail
          ]

          usersCollection.append(newElement)

          self?.database.child("users").setValue(usersCollection) { error, _ in
            guard error == nil else {
              completion(false)
              return
            }
            completion(true)
          }
                    
        } else {
          
          let newCollection: [[String: String]] = [
            [
              "name": user.firstName + " " + user.lastName,
              "email": user.safeEmail
            ]
          ]
  
          self?.database.child("users").setValue(newCollection) { error, _ in
            guard error == nil else {
              return
            }
            completion(true)
          }
        }
      }
      completion(true)
    }
  }
  
  public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
    
    database.child("users").observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value as? [[String: String]] else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      
      completion(.success(value))
    }
  }
  
  public func getUserName(with email: String,
                          completion: @escaping (Result<[String: Any], Error>) -> Void) {
    
    database.child(email).observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value as? [String: Any] else {
        completion(.failure(DatabaseError.failedToFetchNameFirebase))
        return
      }
      
      completion(.success(value))
    }
  }
  
  public enum DatabaseError: Error {
    case failedToFetch
    case failedToFetchNameFirebase
  }
}

extension DataBaseManager {
  
  public func createNewConversation(with otherUserEmail: String,
                                    name: String,
                                    firstMessage: Message,
                                    completion: @escaping (Bool) -> Void){
    
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
          let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
      
      return
    }
    let safeEmail = DataBaseManager.safeEmail(email: currentEmail)
    let reference = database.child(safeEmail)
    
    reference.observeSingleEvent(of: .value) { [weak self] snapshot in
      guard var userNode = snapshot.value as? [String: Any] else {
        completion(false)
        return
      }
      
      let messageDate = firstMessage.sentDate
      let dateString = ChatWithPersonViewController.dateFormatter.string(from: messageDate)
      
      var message = ""
      
      switch firstMessage.kind {
      
      case .text(let messageText):
        message = messageText
      case .attributedText(_):
        break
      case .photo(let mediaItem):
        if let targetUrlString = mediaItem.url?.absoluteString {
          message = targetUrlString
        }
        break
      case .video(let mediaItem):
        if let targetUrlString = mediaItem.url?.absoluteString {
          message = targetUrlString
        }
        break
      case .location(let locationData):
        let location = locationData.location
        message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
        break
      case .emoji(_):
        break
      case .audio(_):
        break
      case .contact(_):
        break
      case .linkPreview(_):
        break
      case .custom(_):
        break
      }
      
      var conversationId = "conversation_\(firstMessage.messageId)"
      
      conversationId = conversationId.replacingOccurrences(of: ".", with: "")
      
      let newConversations: [String: Any] = [
        "id": conversationId,
        "other_user_email": otherUserEmail,
        "name": name,
        "latest_message": [
          "date": dateString,
          "message": message,
          "type": firstMessage.kind.messageKindString,
          "is_read": false
        ]
      ]
      
      let recipientNewConversations: [String: Any] = [
        "id": conversationId,
        "other_user_email": safeEmail,
        "name": currentName,
        "latest_message": [
          "date": dateString,
          "message": message,
          "type": firstMessage.kind.messageKindString,
          "is_read": false
        ]
      ]
      
      self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
        if var conversations = snapshot.value as? [[String: Any]] {
          
          conversations.append(recipientNewConversations)
          self?.database.child("\(otherUserEmail)/conversations").setValue(conversationId)
          
        } else {
          self?.database.child("\(otherUserEmail)/conversations").setValue([recipientNewConversations])
        }
      }
      
      if var conversations = userNode["conversations"] as? [[String: Any]] {
        
        conversations.append(newConversations)
        userNode["conversations"] = conversations
        reference.setValue(userNode) { [weak self] error, _ in
          guard error == nil else {
            completion(false)
            return
          }
          
          self?.finishCreatingConversation(conversationID: conversationId,
                                           name: name,
                                           firstMessage: firstMessage,
                                           completion: completion)
        }
        
      } else {
        
        userNode["conversations"] = [newConversations]
        
        reference.setValue(userNode) { [weak self] error, _ in
          guard error == nil else {
            completion(false)
            return
          }
          
          self?.finishCreatingConversation(conversationID: conversationId,
                                           name: name,
                                           firstMessage: firstMessage,
                                           completion: completion)
        }
      }
    }
  }
  
  private func finishCreatingConversation(conversationID: String,
                                          name: String,
                                          firstMessage: Message,
                                          completion: @escaping (Bool) -> Void) {
    
    let messageDate = firstMessage.sentDate
    let dateString = ChatWithPersonViewController.dateFormatter.string(from: messageDate)
    
    var content = ""
    
    switch firstMessage.kind {
    case .text(let messageText):
      content = messageText
    case .attributedText(_):
      break
    case .photo(let mediaItem):
      if let targetUrlString = mediaItem.url?.absoluteString {
        content = targetUrlString
      }
      break
    case .video(let mediaItem):
      if let targetUrlString = mediaItem.url?.absoluteString {
        content = targetUrlString
      }
      break
    case .location(let locationData):
      let location = locationData.location
      content = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
      break
    case .emoji(_):
      break
    case .audio(_):
      break
    case .contact(_):
      break
    case .linkPreview(_):
      break
    case .custom(_):
      break
    }
    
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      completion(false)
      return
    }
    
    let currentEmail = DataBaseManager.safeEmail(email: myEmail)
    
    let collectionMessage: [String: Any] = [
      "id": firstMessage.messageId,
      "type": firstMessage.kind.messageKindString,
      "content": content,
      "date": dateString,
      "sender_email": currentEmail,
      "is_read": false,
      "name": name
    ]
    
    let value: [String: Any] = [
      "messages": [
        collectionMessage
      ]
    ]
        
    database.child("\(conversationID)").setValue(value) { error, _ in
      guard error == nil else {
        completion(false)
        return
      }
      completion(true)
    }
  }
  
  public func getAllConversations(for email: String,
                                  completion: @escaping (Result<[ChatModel], Error>) -> Void) {
    
    database.child("\(email)/conversations").observe(.value) { snapshot in
      guard let value = snapshot.value as? [[String: Any]] else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      let conversations: [ChatModel] = value.compactMap { dictionary in
        guard let conversationId = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let otherUserEmail = dictionary["other_user_email"] as? String,
              let latestMessage = dictionary["latest_message"] as? [String: Any],
              let date = latestMessage["date"] as? String,
              let type = latestMessage["type"] as? String,
              let message = latestMessage["message"] as? String,
              let isRead = latestMessage["is_read"] as? Bool else {
          return nil
        }
        
        let lastMessageObject = LatestMessage(date: date,
                                              text: message,
                                              type: type,
                                              isRead: isRead)
        
        return ChatModel(id: conversationId,
                         name: name,
                         otherUserEmail: otherUserEmail,
                         latestMessage: lastMessageObject)
      }
      
      completion(.success(conversations))
    }
  }
  
  public func getAllMessagesForConversation(with id: String,
                                            completion: @escaping (Result<[Message], Error>) -> Void) {
    
    database.child("\(id)/messages").observe(.value) { snapshot in
      guard let value = snapshot.value as? [[String: Any]] else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      let messages: [Message] = value.compactMap { dictionary in
        guard let name = dictionary["name"] as? String,
              let _ = dictionary["is_read"] as? Bool,
              let messageID = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let senderEmail = dictionary["sender_email"] as? String,
              let type = dictionary["type"] as? String,
              let dateString = dictionary["date"] as? String,
              let date = ChatWithPersonViewController.dateFormatter.date(from: dateString) else {
          return nil
        }
        
        var kind: MessageKind?
        
        if type == "photo" {
          
          guard let imageUrl = URL(string: content),
                let placeHolder = UIImage(systemName: "plus") else {
            return nil
          }
          
          let media = Media(url: imageUrl,
                            image: nil,
                            placeholderImage: placeHolder,
                            size: CGSize(width: 300, height: 300))
          kind = .photo(media)
          
        } else if type == "video" {
          
          guard let videoUrl = URL(string: content),
                let placeHolder = UIImage(systemName: "play.rectangle") else {
            return nil
          }
          
          let media = Media(url: videoUrl,
                            image: nil,
                            placeholderImage: placeHolder,
                            size: CGSize(width: 300, height: 300))
          kind = .video(media)
           
        } else if type == "location" {
          let locationComponents = content.components(separatedBy: ",")
          guard let longitude = Double(locationComponents[0]),
                let latitude = Double(locationComponents[1]) else {
            return nil
          }
          
          let location = Location(location: CLLocation(latitude: latitude,
                                                       longitude: longitude),
                                  size: CGSize(width: 300, height: 300))
          kind = .location(location)
          
        } else {
          kind = .text(content)
        }
        
        guard let finalKind = kind else {
          return nil
        }
        
        let sender = Sender(photoURL: "",
                            senderId: senderEmail,
                            displayName: name)
        
        return Message(sender: sender,
                       messageId: messageID,
                       sentDate: date,
                       kind: finalKind)
      }
      
      completion(.success(messages))
    }
  }
  
  public func sendMessage(to conversation: String,
                          otherUserEmail: String,
                          name: String,
                          newMessage: Message,
                          completion: @escaping (Bool) -> Void) {
    
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      completion(false)
      return
    }
    
    let currentEmail = DataBaseManager.safeEmail(email: myEmail)
    
    database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
      guard var currentMessages = snapshot.value as? [[String: Any]] else {
        completion(false)
        return
      }
      
      let messageDate = newMessage.sentDate
      let dateString = ChatWithPersonViewController.dateFormatter.string(from: messageDate)
      
      var message = ""
      
      switch newMessage.kind {
      case .text(let messageText):
        message = messageText
      case .attributedText(_):
        break
      case .photo(let mediaItem):
        if let targetUrlString = mediaItem.url?.absoluteString {
          message = targetUrlString
        }
        break
      case .video(let mediaItem):
        if let targetUrlString = mediaItem.url?.absoluteString {
          message = targetUrlString
        }
        break
      case .location(let locationData):
        let location = locationData.location
        message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
        break
      case .emoji(_):
        break
      case .audio(_):
        break
      case .contact(_):
        break
      case .linkPreview(_):
        break
      case .custom(_):
        break
      }

      let newMessageEntry: [String: Any] = [
        "id": newMessage.messageId,
        "type": newMessage.kind.messageKindString,
        "content": message,
        "date": dateString,
        "sender_email": currentEmail,
        "is_read": false,
        "name": name
      ]
      
      currentMessages.append(newMessageEntry)
      
      self?.database.child("\(conversation)/messages").setValue(currentMessages,
                                                                withCompletionBlock: { error, _ in
        guard error == nil else{
          completion(false)
          return
        }
        
        self?.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value,
                                                                                 with: { snapshot in
          
          var databaseEntryConversations = [[String: Any]]()
          
          let updateValue: [String: Any] = [
            "date": dateString,
            "is_read": false,
            "type": newMessage.kind.messageKindString,
            "message": message
          ]
          if var currentUserConversations = snapshot.value as? [[String: Any]] {
            
            var targetConversation: [String: Any]?
            var position = 0
            
            for conversationDictionary in currentUserConversations {
              if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                targetConversation = conversationDictionary
                break
              }
              position += 1
            }
            
            if var targetConversation = targetConversation {
              targetConversation["latest_message"] = updateValue
              currentUserConversations[position] = targetConversation
              databaseEntryConversations = currentUserConversations
            }
            else {
              let newConversations: [String: Any] = [
                "id": conversation,
                "other_user_email": DataBaseManager.safeEmail(email: otherUserEmail),
                "name": name,
                "latest_message": updateValue
              ]
              currentUserConversations.append(newConversations)
              databaseEntryConversations = currentUserConversations
            }
            
          } else {
            let newConversations: [String: Any] = [
              "id": conversation,
              "other_user_email": DataBaseManager.safeEmail(email: otherUserEmail),
              "name": name,
              "latest_message": updateValue
            ]
            databaseEntryConversations = [newConversations]
          }
          
          self?.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations,
                                                                    withCompletionBlock: { error, _ in
            guard error == nil else{
              completion(false)
              return
            }
          })
        })
        
        
        self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value,
                                                                                 with: { snapshot in
          let updateValue: [String: Any] = [
            "date": dateString,
            "is_read": false,
            "type": newMessage.kind.messageKindString,
            "message": message
          ]
          var databaseEntryConversations = [[String: Any]]()
          
          guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
          
          if var otherUserConversations = snapshot.value as? [[String: Any]] {
            
            var targetConversation: [String: Any]?
            var position = 0
            
            for conversationDictionary in otherUserConversations {
              if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                targetConversation = conversationDictionary
                break
              }
              position += 1
            }
            
            if var targetConversation = targetConversation {
              targetConversation["latest_message"] = updateValue
              otherUserConversations[position] = targetConversation
              databaseEntryConversations = otherUserConversations
              
            } else {
              let newConversations: [String: Any] = [
                "id": conversation,
                "other_user_email": DataBaseManager.safeEmail(email: otherUserEmail),
                "name": currentName,
                "latest_message": updateValue
              ]
              otherUserConversations.append(newConversations)
              databaseEntryConversations = otherUserConversations
            }
            
          } else {
            let newConversations: [String: Any] = [
              "id": conversation,
              "other_user_email": DataBaseManager.safeEmail(email: currentEmail),
              "name": currentName,
              "latest_message": updateValue
            ]
            databaseEntryConversations = [newConversations]
          }
          
          self?.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations,
                                                                    withCompletionBlock: { error, _ in
            guard error == nil else{
              completion(false)
              return
            }
          })
        })
      
        completion(true)
      })
    }
  }
  
  public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return
    }
    
    let safeEmail = DataBaseManager.safeEmail(email: email)
    
    let reference = database.child("\(safeEmail)/conversations")
    
    reference.observeSingleEvent(of: .value) { snapshot in
      if var conversations = snapshot.value as? [[String: Any]] {
        var positionToRemove = 0
        for conversation in conversations {
          if let id = conversation["id"] as? String, id == conversationId {
            break
          }
          positionToRemove += 1
        }
        
        conversations.remove(at: positionToRemove)
        
        reference.setValue(conversations) { error, _ in
          guard error == nil else {
            completion(false)
            return
          }
          completion(true)
        }
      }
    }
  }
  
  public func conversationExists(with targetRecipientEmail: String,
                                 completion: @escaping (Result<String, Error>) -> Void) {
    let safeRecipientEmail = DataBaseManager.safeEmail(email: targetRecipientEmail)
    
    guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
    
    let safeSenderEmail = DataBaseManager.safeEmail(email: senderEmail)
    
    database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
      guard let collection = snapshot.value as? [[String: Any]] else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      
      if let conversation = collection.first(where: {
        guard let targetSenderEmail = $0["other_user_email"] as? String else { return false }
        
        return safeSenderEmail == targetSenderEmail
      }) {
        
        guard let id = conversation["id"] as? String else {
          completion(.failure(DatabaseError.failedToFetch))
          return
        }
        completion(.success(id))
        return
      }
      
      completion(.failure(DatabaseError.failedToFetch))
      return
    }
  }
}
