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
  var modelProfile = [ProfileModel]()
  var sameEmailUser = ""
  
  override func loadView() {
    super.loadView()
    view = profileView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
    if sameEmailUser != email {
      configureTableView()
      sameEmailUser = email
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBlue
    setupNavigation()
    setupTableView()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(assingEmptyHeaderTableView),
                                           name:Notification.Name("AssingEmptyHeaderTableView"), object: nil)
  }
  
  @objc func assingEmptyHeaderTableView() {
    modelMessenger = []
    DispatchQueue.main.async { [weak self] in
      self?.profileView.tableView.reloadData()
    }
  }
  
  private func setupNavigation() {
    title = "Profile"
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  private func configureTableView() {
    
    profileView.tableView.register(ProfileTableViewCell.self,
                                   forCellReuseIdentifier: ProfileTableViewCell.identifier)
    
    profileView.tableView.register(ProfileHeaderTableView.self,
                                   forHeaderFooterViewReuseIdentifier: ProfileHeaderTableView.identifier)
    
    profileView.tableView.dataSource = self
    profileView.tableView.delegate = self
    profileView.tableView.reloadData()
  }
  
  private func setupTableView() {
    
    modelProfile.append(ProfileModel(modelType: .logout,
                                     title: "Log Out",
                                     handler: { [weak self] in
      
      let actionSheet = UIAlertController(title: "Are you sure want to log out?", message: "Presse button Log out to log out.", preferredStyle: .actionSheet)
      
      actionSheet.addAction(UIAlertAction(title: "Log out",
                                          style: .destructive,
                                          handler: { [weak self] _ in
        
        UserDefaults.standard.setValue(nil, forKey: "email")
        UserDefaults.standard.setValue(nil, forKey: "name")
        
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
          NotificationCenter.default.post(name: Notification.Name("AssingEmptyTableView"), object: nil)
          NotificationCenter.default.post(name: Notification.Name("AssingEmptyHeaderTableView"), object: nil)
          navigantion.modalPresentationStyle = .fullScreen
          self?.present(navigantion, animated: false, completion: {
            self?.tabBarController?.selectedIndex = 0
          })
        }
        catch {
          print("Falied Log out")
        }
      }))
      
      actionSheet.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel))
      
      self?.present(actionSheet, animated: true)
    }))
  }
}

extension ProfileViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return modelProfile.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else { return .init()}
    let viewModel = modelProfile[indexPath.row]
    cell.configure(with: viewModel)
    return cell
  }
}

extension ProfileViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    modelProfile[indexPath.row].handler?()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerProfile = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileHeaderTableView.identifier) as? ProfileHeaderTableView else { return .init() }
    
    headerProfile.spinner.show(in: headerProfile.imageView)
    
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return .init() }
    sameEmailUser = email
    guard let name = UserDefaults.standard.value(forKey: "name") as? String else { return .init() }
    
    let safeEmail = DataBaseManager.safeEmail(email: email)
    let fileName = safeEmail + "_profile_picture.png"
    let path = "images/" + fileName
    
    StorageManager.shared.downloadURL(for: path) { result in
      switch result {
      case .success(let url):
        headerProfile.configure(url: url, name: name)
      case .failure(let error):
        print("Error \(error)")
      }
    }
    return headerProfile
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    300
  }
}
