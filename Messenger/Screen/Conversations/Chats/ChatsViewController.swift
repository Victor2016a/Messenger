//
//  ChatsViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import UIKit

class ChatsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .orange
    title = "Chats"
    navigationController?.navigationBar.prefersLargeTitles = true
  }
}
