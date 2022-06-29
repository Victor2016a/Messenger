//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
  var profileView = ProfileView()
  var modelMessenger = [MessengerModel]()
  
  override func loadView() {
    super.loadView()
    view = profileView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBlue
    setupNavigation()
    configureTableView()
  }
  
  private func setupNavigation() {
    title = "Profile"
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  private func configureTableView() {
    
    profileView.tableView.register(UITableViewCell.self,
                                   forCellReuseIdentifier: "cell")
    
    profileView.tableView.register(ProfileHeaderTableView.self,
                                   forHeaderFooterViewReuseIdentifier: ProfileHeaderTableView.identifier)
    
    profileView.tableView.dataSource = self
    profileView.tableView.delegate = self
  }
}

extension ProfileViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "Log out"
    cell.textLabel?.textColor = .red
    return cell
  }
}

extension ProfileViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Log out",
                                        style: .destructive,
                                        handler: { [weak self] _ in
      
      FBSDKLoginKit.LoginManager().logOut()
      
      let firebaseAuth = Auth.auth()
      do {
        try firebaseAuth.signOut()
      } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
      }
      
      do {
        try FirebaseAuth.Auth.auth().signOut()
        let loginVC = LoginViewController()
        let navigantion = UINavigationController(rootViewController: loginVC)
        
        navigantion.modalPresentationStyle = .fullScreen
        self?.present(navigantion, animated: true)
      }
      catch {
        print("Falied Log out")
      }
      
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel))
    
    present(actionSheet, animated: true)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerProfile = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileHeaderTableView.identifier) as? ProfileHeaderTableView else { return .init() }
    
    headerProfile.spinner.show(in: headerProfile)
    
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return .init()}
    
    let safeEmail = DataBaseManager.safeEmail(email: email)
    let fileName = safeEmail + "_profile_picture.png"
    let path = "images/" + fileName
    
    StorageManager.shared.downloadURL(for: path) { result in
      switch result {
      case .success(let url):
        headerProfile.configure(url: url)
      case .failure(let error):
        print("Error \(error)")
      }
    }
    return headerProfile
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    200
  }
}
