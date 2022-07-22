//
//  ViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    validateAuth()
    setupView()
  }
  
  private func setupView() {
    let tabBarVC = UITabBarController()
    let chatsVC = UINavigationController(rootViewController: ChatsViewController())
    let profileVC = UINavigationController(rootViewController: ProfileViewController())
    
    chatsVC.tabBarItem.image = UIImage(systemName: "message")
    profileVC.tabBarItem.image = UIImage(systemName: "person")
    
    tabBarVC.setViewControllers([chatsVC,profileVC], animated: false)
    tabBarVC.modalPresentationStyle = .fullScreen
    tabBarVC.tabBar.backgroundColor = .systemBackground
    
    present(tabBarVC, animated: false, completion: nil)
  }
  
  private func validateAuth() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      let loginVC = LoginViewController()
      let navigantion = UINavigationController(rootViewController: loginVC)
      
      navigantion.modalPresentationStyle = .fullScreen
      present(navigantion, animated: true)
    }
  }
}
