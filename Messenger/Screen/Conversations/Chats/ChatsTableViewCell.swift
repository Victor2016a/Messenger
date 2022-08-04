//
//  ChatsTableViewCell.swift
//  Messenger
//
//  Created by Victor Vieira on 10/06/22.
//

import UIKit
import SDWebImage

class ChatsTableViewCell: UITableViewCell {
  static let identifier = "ChatsTableViewCell"
    
  private let userImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 45
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let userNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 21, weight: .semibold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let userMessageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 19, weight: .regular)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupCell()
    setupCellConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with model: ChatModel) {
    contentView.backgroundColor = .secondarySystemBackground
    userNameLabel.text = model.name
    
    let type = model.latestMessage.type
    
    switch type {
    case "photo":
      userMessageLabel.text = "Photo"
    case "video":
      userMessageLabel.text = "Video"
    case "location":
      userMessageLabel.text = "Location"
    default:
      userMessageLabel.text = model.latestMessage.text
    }
    
    let path = "images/\(model.otherUserEmail)_profile_picture.png"
    
    print(path)
    StorageManager.shared.downloadURL(for: path) { [weak self] result in
      switch result {
      case .success(let url):
        ImageProvider.shared.fecthImage(url: url) { image in
          DispatchQueue.main.async {
            self?.userImageView.image = image
          }
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
  private func setupCell() {
    contentView.addSubview(userImageView)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(userMessageLabel)
  }
  
  private func setupCellConstraints() {
    NSLayoutConstraint.activate([
      userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      userImageView.widthAnchor.constraint(equalToConstant: 90),
      userImageView.heightAnchor.constraint(equalToConstant: 90),
      
      userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
      userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 15),
      userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      userNameLabel.heightAnchor.constraint(equalToConstant: 40),
      
      userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
      userMessageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 15),
      userMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      userMessageLabel.heightAnchor.constraint(equalToConstant: 40)
    ])
  }
}
