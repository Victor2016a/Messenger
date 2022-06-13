//
//  ChatWithPersonViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 13/06/22.
//

import UIKit
import MessageKit

class ChatWithPersonViewController: MessagesViewController {
  
  private var messages = [Message]()
  
  let selfSender = Sender(photoURL: "",
                          senderId: "1",
                          displayName: "Yan")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    configureMessages()
  }
  
  private func configureMessages() {
    messages.append(Message(sender: selfSender,
                            messageId: "1",
                            sentDate: Date(),
                            kind: .text("Hello Mannnnnn")))
    
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
  }
}

extension ChatWithPersonViewController: MessagesDataSource {
  func currentSender() -> SenderType {
    return selfSender
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
