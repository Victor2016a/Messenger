//
//  ChatWithPersonViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 13/06/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatWithPersonViewController: MessagesViewController {
  
  public static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .long
    dateFormatter.locale = .current
    return dateFormatter
  }()
  
  public var isNewConversation = false
  private var otherUserEmail: String
  private var conversationId: String?
  private var messages = [Message]()
   
  private var selfSender: Sender? {
    
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    
    let safeEmail = DataBaseManager.safeEmail(email: email)
    
    return Sender(photoURL: "",
           senderId: safeEmail,
           displayName: "Me")
  }
  
  init(email: String, id: String?) {
    self.otherUserEmail = email 
    self.conversationId = id
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    configureMessages()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    messageInputBar.inputTextView.becomeFirstResponder()
    if let conversationId = conversationId {
      listenForMessages(id: conversationId, shouldScrollBotton: true)
    }
  }
  
  private func listenForMessages(id: String, shouldScrollBotton: Bool) {
    DataBaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
      switch result {
      case .success(let messages):
        guard !messages.isEmpty else { return }
        self?.messages = messages
        
        DispatchQueue.main.async {
          self?.messagesCollectionView.reloadDataAndKeepOffset()
          
          if shouldScrollBotton {
            self?.messagesCollectionView.scrollToLastItem()
          }
        }
        
      case .failure(let error):
        print(error)
      }
    }
  }
  
  private func configureMessages() {
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    messageInputBar.delegate = self
  }
}

extension ChatWithPersonViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
    guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
          let selfSender = self.selfSender,
          let messageId = createMessageId() else {
      return
    }
    
    let message = Message(sender: selfSender,
                          messageId: messageId,
                          sentDate: Date(),
                          kind: .text(text))
    
    if isNewConversation {
      
      DataBaseManager.shared.createNewConversation(with: otherUserEmail,
                                                   name: self.title ?? "User",
                                                   firstMessage: message) { [weak self] success in
        
        if success {
          
          self?.isNewConversation = false
          
        } else {
         
          print("Failed to send")
          
        }
      }
      
    } else {
      
      guard let conversationId = conversationId, let name = self.title else { return }
      
      DataBaseManager.shared.sendMessage(to: conversationId,
                                         otherUserEmail: otherUserEmail,
                                         name: name,
                                         newMessage: message) { success in
        if success {
          
        } else {
          
        }
      }
    }
  }
  
  private func createMessageId() -> String? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    
    let currentUserEmail = DataBaseManager.safeEmail(email: email)
    
    let dateString = Self.dateFormatter.string(from: Date())
    let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
    
    print(newIdentifier)
    return newIdentifier
  }
}

extension ChatWithPersonViewController: MessagesDataSource {
  func currentSender() -> SenderType {
    if let sender = selfSender {
      return sender
    }
    fatalError("Self sender is nil, email should be cache")
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
}

extension ChatWithPersonViewController: MessagesLayoutDelegate {
  
}

extension ChatWithPersonViewController: MessagesDisplayDelegate {
  
}
