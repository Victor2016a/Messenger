//
//  ViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit

class ConversationsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
    
    if !isLoggedIn {
      let loginVC = LoginViewController()
      let navigantion = UINavigationController(rootViewController: loginVC)
      
      navigantion.modalPresentationStyle = .fullScreen
      present(navigantion, animated: true)
    }
  }
}
