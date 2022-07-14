//
//  ChatWithPersonViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 13/06/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

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
    setupInputButton()
  }
  
  private func setupInputButton() {
    let button = InputBarButtonItem()
    button.setSize(CGSize(width: 35, height: 35), animated: false)
    button.setImage(UIImage(systemName: "paperclip"), for: .normal)
    button.onTouchUpInside { [weak self]  _ in
      self?.presentInputActionSheet()
    }
    messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
    messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
  }
  
  private func presentInputActionSheet() {
    let actionSheet = UIAlertController(title: "Attach Media",
                                        message: "What would you like to attach?",
                                        preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Photo",
                                        style: .default,
                                        handler: { [weak self] _ in
      self?.presentPhotoInputActionSheet()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Video",
                                        style: .default,
                                        handler: { [weak self] _ in
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Audio",
                                        style: .default,
                                        handler: { [weak self] _ in
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: { [weak self] _ in
    }))
    
    present(actionSheet, animated: true)
  }
  
  private func presentPhotoInputActionSheet() {
    
    let actionSheet = UIAlertController(title: "Attach Photo",
                                        message: "Where would you like to attach a photo from",
                                        preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = self
      picker.allowsEditing = true
      self?.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Photo Library ",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      picker.allowsEditing = true
      self?.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: nil ))
    
    present(actionSheet, animated: true)
    
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
    messagesCollectionView.messageCellDelegate = self
    messageInputBar.delegate = self
  }
}

extension ChatWithPersonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
          let imageData = image.pngData(),
          let messageId = createMessageId(),
          let conversationId = conversationId,
          let name = self.title,
          let selfSender = selfSender else {
      return
    }
     
    let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
    
    StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
      
      guard let otherUserEmail = self?.otherUserEmail else { return }
      
      switch result {
      case .success(let urlString):
        
        guard let url = URL(string: urlString),
              let placeholder = UIImage(systemName: "plus") else { return }
        
        let media = Media(url: url,
                          image: nil,
                          placeholderImage: placeholder,
                          size: .zero)
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .photo(media))
        
        DataBaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
          
        }
        
      case .failure(let error):
        print(error)
      }
    }
    
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
  
  func configureMediaMessageImageView(_ imageView: UIImageView,
                                      for message: MessageType,
                                      at indexPath: IndexPath,
                                      in messagesCollectionView: MessagesCollectionView) {
    
    guard let message = message as? Message else {
      return
    }
    
    switch message.kind {
      
    case .photo(let media):
      guard let imageUrl = media.url else { return }
      imageView.sd_setImage(with: imageUrl)
      
    default:
      break
    }
  }

}

extension ChatWithPersonViewController: MessagesLayoutDelegate {
  
}

extension ChatWithPersonViewController: MessagesDisplayDelegate {
  
}

extension ChatWithPersonViewController: MessageCellDelegate {
  
  func didTapImage(in cell: MessageCollectionViewCell) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messages[indexPath.section]
    
    switch message.kind {
    case .photo(let media):
      
      guard let imageUrl = media.url else { return }
      
      let photoVC = PhotoViewerViewController(with: imageUrl)
      self.navigationController?.pushViewController(photoVC, animated: true)
      
    default:
      break
    }
  }
  
}
