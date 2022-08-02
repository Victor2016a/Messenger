//
//  ProfileHeaderTableView.swift
//  Messenger
//
//  Created by Victor Vieira on 17/06/22.
//

import UIKit
import JGProgressHUD

class ProfileHeaderTableView: UITableViewHeaderFooterView {
  static let identifier = "ProfileHeaderTableView"
  
  let spinner = JGProgressHUD(style: .light)
    
  var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.clipsToBounds = true
    return imageView
  }()
  
  var nameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.font = .boldSystemFont(ofSize: 35)
    label.textAlignment = .center
    return label
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupView()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(url: URL, name: String) {
    nameLabel.text = name
    
    ImageProvider.shared.fecthImage(url: url) { [weak self] image in
      DispatchQueue.main.async {
        self?.spinner.dismiss()
        self?.imageView.image = image
        guard let imageView = self?.imageView else { return }
        imageView.layer.cornerRadius = imageView.bounds.width/2
      }
    }
  }
  
  private func setupView() {
    contentView.addSubview(imageView)
    contentView.addSubview(nameLabel)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
      imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      imageView.heightAnchor.constraint(equalToConstant: 200),
      imageView.widthAnchor.constraint(equalToConstant: 200),
      
      nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
      nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
    ])
  }
}
