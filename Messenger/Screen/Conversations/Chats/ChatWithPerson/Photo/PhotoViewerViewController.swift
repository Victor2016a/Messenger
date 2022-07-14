//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {
  private let photoView = PhotoView()
  private let url: URL

  init(with url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    view = photoView
  }
  
  private func setupView() {
    title = "Photo"
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .black
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    photoView.imageView.sd_setImage(with: self.url)
  }
}
