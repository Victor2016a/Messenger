//
//  NewConversationTableViewCell.swift
//  Messenger
//
//  Created by Victor Vieira on 15/07/22.
//

import UIKit
import SDWebImage

class NewConversationTableViewCell: UITableViewCell {
  static let identifier = "NewConversationTableViewCell"
    
  private let userImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 35
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
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupCell()
    setupCellConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with model: NewConversationModel) {
    let path = "images/\(model.email)_profile_picture.png"
    self.userNameLabel.text = model.name
    
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
  }
  
  private func setupCellConstraints() {
    NSLayoutConstraint.activate([
      userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      userImageView.widthAnchor.constraint(equalToConstant: 70),
      userImageView.heightAnchor.constraint(equalToConstant: 70),
      
      userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
      userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
      userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      userNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
}
