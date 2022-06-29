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
  private var messages = [Message]()
  
  private var selfSender: Sender? {
    
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    
    return Sender(photoURL: "",
           senderId: email,
           displayName: "Yan")
  }
  
  init(email: String) {
    self.otherUserEmail = email
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
    
    if isNewConversation {
      
      let message = Message(sender: selfSender,
                            messageId: messageId,
                            sentDate: Date(),
                            kind: .text(text))
      
      DataBaseManager.shared.createNewConversation(with: otherUserEmail,
                                                   firstMessage: message) { sucess in
        
      }
      
    } else {
      
    }
  }
  
  private func createMessageId() -> String? {
    guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else { return nil }
    
    let dateString = Self.dateFormatter.string(from: Date())
    let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
    
    return newIdentifier
  }
}

extension ChatWithPersonViewController: MessagesDataSource {
  func currentSender() -> SenderType {
    if let sender = selfSender {
      return sender
    }
    fatalError("Self sender is nil, email should be cache")
    
    return Sender(photoURL: "", senderId: "12", displayName: "")
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.row]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
}

extension ChatWithPersonViewController: MessagesLayoutDelegate {
  
}

extension ChatWithPersonViewController: MessagesDisplayDelegate {
  
}
