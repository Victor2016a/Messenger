//
//  ChatWithPersonTableViewCell.swift
//  Messenger
//
//  Created by Victor Vieira on 30/06/22.
//

import UIKit

class ChatWithPersonTableViewCell: UITableViewCell {
  static let identifier = "ChatWithPersonTableViewCell"
  
  private let userImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 50
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  private let userNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 21, weight: .semibold)
    return label
  }()
  
  private let userMessageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 19, weight: .regular)
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
  
  private func setupCell() {
    contentView.addSubview(userImageView)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(userMessageLabel)
  }
  
  private func setupCellConstraints() {
    NSLayoutConstraint.activate([
      
    ])
  }
}
