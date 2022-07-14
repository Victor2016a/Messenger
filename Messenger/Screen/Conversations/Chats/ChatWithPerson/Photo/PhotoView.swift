//
//  PhotoView.swift
//  Messenger
//
//  Created by Victor Vieira on 14/07/22.
//

import UIKit

class PhotoView: UIView {
  
  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupView()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    addSubview(imageView)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
