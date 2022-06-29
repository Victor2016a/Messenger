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
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupView()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(url: URL) {
    ImageProvider.shared.fecthImage(url: url) { [weak self] image in
      DispatchQueue.main.async {
        self?.spinner.dismiss()
        self?.imageView.image = image
      }
    }
  }
  
  private func setupView() {
    contentView.addSubview(imageView)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
      imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
    ])
  }
}
