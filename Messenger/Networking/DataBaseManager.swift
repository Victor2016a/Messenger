//
//  DataBaseManager.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import Foundation
import FirebaseDatabase

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
    self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      completion(.success(value))
    }
  }
}


extension DataBaseManager {
  public func emailExists(with email: String, completion: @escaping ((Bool) -> Void)) {
    
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    
    database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
      guard snapshot.value as? String != nil else {
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
    ]) { error, _ in
      guard error == nil else {
        print("Failed to write to database")
        completion(false)
        return
      }
      
      self.database.child("users").observeSingleEvent(of: .value) { snapShot in
        if var usersCollection = snapShot.value as? [[String: String]] {
          
//          let newElement = [
//              "name": user.firstName + " " + user.lastName,
//              "email": user.safeEmail
//          ]
//
//          usersCollection.append(newElement)
//
//          self.database.child("users").setValue(usersCollection) { error, _ in
//            guard error == nil else {
//              completion(false)
//              return
//            }
//            completion(true)
//          }
                    
        } else {
          
          let newCollection: [[String: String]] = [
            [
              "name": user.firstName + " " + user.lastName,
              "email": user.safeEmail
            ]
          ]
  
          self.database.child("users").setValue(newCollection) { error, _ in
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
  
  public enum DatabaseError: Error {
    case failedToFetch
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
      case .photo(_):
        break
      case .video(_):
        break
      case .location(_):
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
    case .photo(_):
      break
    case .video(_):
      break
    case .location(_):
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
              let message = latestMessage["message"] as? String,
              let isRead = latestMessage["is_read"] as? Bool else {
          return nil
        }
        
        let lastMessageObject = LatestMessage(date: date,
                                              text: message,
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
              let isRead = dictionary["is_read"] as? Bool,
              let messageID = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let senderEmail = dictionary["sender_email"] as? String,
              let type = dictionary["type"] as? String,
              let dateString = dictionary["date"] as? String,
              let date = ChatWithPersonViewController.dateFormatter.date(from: dateString) else {
          return nil
        }
        
        let sender = Sender(photoURL: "",
                            senderId: senderEmail,
                            displayName: name)
        
        return Message(sender: sender,
                       messageId: messageID,
                       sentDate: date,
                       kind: .text(content))
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
    
    self.database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
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
      case .photo(_):
        break
      case .video(_):
        break
      case .location(_):
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
          guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
            completion(false)
            return
          }
          
          let updateValue: [String: Any] = [
            "date": dateString,
            "is_read": false,
            "message": message
          ]
          
          var targetConversation: [String: Any]?
          var position = 0
          
          for conversationDictionary in currentUserConversations {
            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
              targetConversation = conversationDictionary
              break
            }
            position += 1
          }
          
          targetConversation?["latest_message"] = updateValue
          
          guard let finalConversation = targetConversation else {
            completion(false)
            return
          }
          currentUserConversations[position] = finalConversation
          self?.database.child("\(currentEmail)/messages").setValue(currentUserConversations,
                                                                    withCompletionBlock: { error, _ in
            guard error == nil else{
              completion(false)
              return
            }
          })
        })
        
        
        self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value,
                                                                                 with: { snapshot in
          guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
            completion(false)
            return
          }
          
          let updateValue: [String: Any] = [
            "date": dateString,
            "is_read": false,
            "message": message
          ]
          
          var targetConversation: [String: Any]?
          var position = 0
          
          for conversationDictionary in otherUserConversations {
            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
              targetConversation = conversationDictionary
              break
            }
            position += 1
          }
          
          targetConversation?["latest_message"] = updateValue
          
          guard let finalConversation = targetConversation else {
            completion(false)
            return
          }
          otherUserConversations[position] = finalConversation
          self?.database.child("\(otherUserEmail)/messages").setValue(otherUserConversations,
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
}
