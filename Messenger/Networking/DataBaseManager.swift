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
      "firstName": user.firstName,
      "lastName": user.lastName
    ]) { error, _ in
      guard error == nil else {
        print("Failed to write to database")
        completion(false)
        return
      }
      
      self.database.child("users").observeSingleEvent(of: .value) { snapShot in
        if var usersCollection = snapShot.value as? [[String: String]] {
          
          let newElement = [
              "name": user.firstName + " " + user.lastName,
              "email": user.safeEmail
          ]
          
          usersCollection.append(newElement)
          
          self.database.child("users").setValue(usersCollection) { error, _ in
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
                                    firstMessage: Message,
                                    completion: @escaping (Bool) -> Void){
    
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
    
    let safeEmail = DataBaseManager.safeEmail(email: currentEmail)
    let reference = database.child(safeEmail)
    
    reference.observeSingleEvent(of: .value) { snapshot in
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
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      
      if var conversations = userNode["conversations"] as? [[String: Any]] {
        
        conversations.append(newConversations)
        userNode["conversations"] = conversations
        reference.setValue(userNode) { [weak self] error, _ in
          guard error == nil else {
            completion(false)
            return
          }
          
          self?.finishCreatingConversation(conversationID: conversationId,
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
                                           firstMessage: firstMessage,
                                           completion: completion)
        }
      }
    }
  }
  
  private func finishCreatingConversation(conversationID: String,
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
      "is_read": false
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
                                  completion: @escaping (Result<String, Error>) -> Void) {
    
  }
  
  public func getAllMessagesForConversation(with id: String,
                                            completion: @escaping (Result<String, Error>) -> Void) {
    
  }
  
  public func sendMessage(to conversation: String, message: Message,
                          completion: @escaping (Bool) -> Void) {
    
  }
}
