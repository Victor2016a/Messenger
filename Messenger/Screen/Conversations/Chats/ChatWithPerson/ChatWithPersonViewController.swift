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
import CoreLocation
import AVKit

class ChatWithPersonViewController: MessagesViewController {
  private var senderPhotoUrl: URL?
  private var otherPhotoUrl: URL?
  
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
      self?.presentVideoInputActionSheet()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Audio",
                                        style: .default,
                                        handler: { _ in
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Location",
                                        style: .default,
                                        handler: { [weak self] _ in
      self?.presentLocationPicker()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: { _ in
    }))
    
    present(actionSheet, animated: true)
  }
  
  private func presentLocationPicker() {
    let locationVC = LocationPickerViewController(coordinates: nil, isPickable: true)
    locationVC.title = "Pick Location"
    locationVC.navigationItem.largeTitleDisplayMode = .never
    locationVC.completion = { [weak self] selectedCoordinator in
      
      guard let messageId = self?.createMessageId(),
            let conversationId = self?.conversationId,
            let name = self?.title,
            let selfSender = self?.selfSender else {
        return
      }
      
      let latitude = selectedCoordinator.latitude
      let longitude = selectedCoordinator.longitude
      
      let location = Location(location: CLLocation(latitude: latitude,
                                                   longitude: longitude), size: .zero)
      
      let message = Message(sender: selfSender,
                            messageId: messageId,
                            sentDate: Date(),
                            kind: .location(location))
      
      guard let otherUserEmail = self?.otherUserEmail else { return }
      
      DataBaseManager.shared.sendMessage(to: conversationId,
                                         otherUserEmail: otherUserEmail,
                                         name: name,
                                         newMessage: message) { success in
        
      }
    }
    navigationController?.pushViewController(locationVC, animated: true)
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
  
  private func presentVideoInputActionSheet() {
    
    let actionSheet = UIAlertController(title: "Attach Video",
                                        message: "Where would you like to attach a video from",
                                        preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = self
      picker.allowsEditing = true
      picker.mediaTypes = ["public.movie"]
      picker.videoQuality = .typeMedium
      self?.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Library",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      picker.allowsEditing = true
      picker.mediaTypes = ["public.movie"]
      picker.videoQuality = .typeMedium
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
    
    guard let messageId = createMessageId(),
          let conversationId = conversationId,
          let name = self.title,
          let selfSender = selfSender else {
      return
    }
    
    if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
       let imageData = image.pngData() {
      
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
    } else if let videoUrl = info[.mediaURL] as? URL {
      
      let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "_") + ".mov"
      
      StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
        
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
                                kind: .video(media))
          
          DataBaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
            
          }
          
        case .failure(let error):
          print(error)
        }
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
          let messageId = message.messageId.replacingOccurrences(of: ".", with: "")
          let newConversationId = "conversation_\(messageId)"
          self?.conversationId = newConversationId
          self?.listenForMessages(id: newConversationId, shouldScrollBotton: true)
          self?.messageInputBar.inputTextView.text = nil
        } else {
          print("Failed to send")
        }
      }
    } else {
      
      guard let conversationId = conversationId, let name = self.title else { return }
      
      DataBaseManager.shared.sendMessage(to: conversationId,
                                         otherUserEmail: otherUserEmail,
                                         name: name,
                                         newMessage: message) { [weak self] success in
        if success {
          self?.messageInputBar.inputTextView.text = nil
          print("Send Message")
        } else {
          print("failed Message")
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
  
  func backgroundColor(for message: MessageType,
                       at indexPath: IndexPath,
                       in messagesCollectionView: MessagesCollectionView) -> UIColor {
    let sender = message.sender
    if sender.senderId == selfSender?.senderId {
      return .link
    }
    return .secondarySystemBackground
  }
  
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let sender = message.sender
    
    if sender.senderId == selfSender?.senderId {
      
      if let currentUserImageUrl = self.senderPhotoUrl {
        avatarView.sd_setImage(with: currentUserImageUrl, completed: nil)
        
      } else {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DataBaseManager.safeEmail(email: email)
        let path = "images/\(safeEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
          switch result {
          case .success(let url):
            self?.senderPhotoUrl = url
            DispatchQueue.main.async {
              avatarView.sd_setImage(with: url, completed: nil)
            }
          case .failure(let error):
            print(error)
          }
        }
      }
      
    } else {
      
      if let otherUserPhotoUrl = self.otherPhotoUrl {
        avatarView.sd_setImage(with: otherUserPhotoUrl, completed: nil)
        
      } else {
        
        let email = self.otherUserEmail
        let safeEmail = DataBaseManager.safeEmail(email: email)
        let path = "images/\(safeEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
          switch result {
          case .success(let url):
            self?.otherPhotoUrl = url
            DispatchQueue.main.async {
              avatarView.sd_setImage(with: url, completed: nil)
            }
          case .failure(let error):
            print(error)
          }
        }
      }
    }
  }
}

extension ChatWithPersonViewController: MessagesLayoutDelegate {
  
}

extension ChatWithPersonViewController: MessagesDisplayDelegate {
  
}

extension ChatWithPersonViewController: MessageCellDelegate {
  
  func didTapMessage(in cell: MessageCollectionViewCell) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messages[indexPath.section]
    
    switch message.kind {
    case .location(let locationData):
      let coordinates = locationData.location.coordinate
      let locationVC = LocationPickerViewController(coordinates: coordinates, isPickable: false)
      navigationController?.pushViewController(locationVC, animated: true)
    default:
      break
    }
  }
  
  func didTapImage(in cell: MessageCollectionViewCell) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messages[indexPath.section]
    
    switch message.kind {
    case .photo(let media):
      
      guard let imageUrl = media.url else { return }
      
      let photoVC = PhotoViewerViewController(with: imageUrl)
      navigationController?.pushViewController(photoVC, animated: true)
     
    case .video(let media):
      
      guard let videoUrl = media.url else { return }
      
      let viewControllerAV = AVPlayerViewController()
      viewControllerAV.player = AVPlayer(url: videoUrl)
      
      present(viewControllerAV, animated: true)
      
    default:
      break
    }
  }
  
}
