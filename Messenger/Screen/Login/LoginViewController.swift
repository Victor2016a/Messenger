//
//  LoginViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {
  let loginView = LoginView()
  
  override func loadView() {
    super.loadView()
    view = loginView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    title = "Log In"
    view.backgroundColor = .systemBackground
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(didTapRegisterButton))
    
    loginView.loginButton.addTarget(self,
                                    action: #selector(didTapLoginButton),
                                    for: .touchUpInside)
    
    loginView.googleLoginButton.addTarget(self,
                                          action: #selector(didTapGoogleButton),
                                          for: .touchUpInside)
    
    loginView.emailTextField.delegate = self
    loginView.passwordTextField.delegate = self
    loginView.facebookLoginButton.delegate = self
  }
  
  @objc private func didTapLoginButton() {
    loginView.emailTextField.resignFirstResponder()
    loginView.passwordTextField.resignFirstResponder()
    
    guard let email = loginView.emailTextField.text,
          let password = loginView.passwordTextField.text,
          !email.isEmpty,
          !password.isEmpty,
          password.count >= 6 else {
      alertUserLoginError()
      return
    }
    
    loginView.spinner.show(in: view)
    
    FirebaseAuth.Auth.auth().signIn(withEmail: email,
                                    password: password) { [weak self] authResult, error in
      
      guard let result = authResult, error == nil else {
        self?.alertLoginErrorEmailPassword()
        return
      }
      
      let user = result.user
      
      UserDefaults.standard.setValue(email, forKey: "email")
      
      let safeEmail = DataBaseManager.safeEmail(email: email)
      
      DataBaseManager.shared.getUserName(with: safeEmail) { result in
        switch result {
        case .success(let collection):
          
          guard let firstName = collection["first_name"] as? String,
                let lastName = collection["last_name"] as? String else {
            return
          }
          
          let name = firstName + " " + lastName
          UserDefaults.standard.setValue(name, forKey: "name")
          
        case .failure(let error):
          print(error)
        }
      }
      
      print("Login In user: \(user)")
      
      DispatchQueue.main.async {
        self?.loginView.spinner.dismiss(animated: true)
      }
      NotificationCenter.default.post(name: Notification.Name("LogIn"), object: nil)
      NotificationCenter.default.post(name: Notification.Name("ProfileSetup"), object: nil)
      self?.navigationController?.dismiss(animated: true)
    }
  }
  
  @objc private func didTapGoogleButton() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    let config = GIDConfiguration(clientID: clientID)
    
    loginView.spinner.show(in: view)
    
    GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] authResult, error in
      
      guard let user = authResult, error == nil else {
        return
      }
            
      let authentication = user.authentication
      guard let firstName = user.profile?.givenName,
            let lastName = user.profile?.familyName,
            let email = user.profile?.email,
            let hasImage = user.profile?.hasImage,
            let idToken = authentication.idToken else { return }
      
      UserDefaults.standard.setValue(email, forKey: "email")
      let name = firstName + " " + lastName
      UserDefaults.standard.setValue(name, forKey: "name")

      DataBaseManager.shared.userExists(with: email) { exists in
        if !exists {
          let chatUser = MessengerModel(firstName: firstName,
                                        lastName: lastName,
                                        email: email)
          
          DataBaseManager.shared.insertUser(with: chatUser) { success in
            if success {
              
              if hasImage {
                guard let url = user.profile?.imageURL(withDimension: 200) else { return }

                URLSession.shared.dataTask(with: url) { data, _ , error in
                  guard let data = data else {
                    return
                  }
                  
                  let fileName = chatUser.profilePictureFileName
                  StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                    switch result {
                    case .success(let downloadUrl):
                      UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                    case .failure(let error):
                      print(error)
                    }
                  }
                }.resume()
              }
            }
          }
        }
      }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: authentication.accessToken)
      
      FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
        guard authResult != nil, error == nil else {
          if let error = error {
            print(error)
          }
          return
        }
        
        DispatchQueue.main.async {
          self?.loginView.spinner.dismiss(animated: true)
        }
        NotificationCenter.default.post(name: Notification.Name("LogIn"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("ProfileSetup"), object: nil)
        self?.navigationController?.dismiss(animated: true)
      }
    }
  }
  
  private func alertUserLoginError() {
    let alertError = UIAlertController(title: "Whoops!",
                                       message: "Please, enter all information to log in.",
                                       preferredStyle: .alert)
    
    alertError.addAction(UIAlertAction(title: "Dismiss",
                                       style: .cancel))
    present(alertError, animated: true)
  }
  
  private func alertLoginErrorEmailPassword() {
    loginView.spinner.dismiss(animated: true)
    let alertError = UIAlertController(title: "Whoops!",
                                       message: "Email or Password incorrect.",
                                       preferredStyle: .alert)
    
    alertError.addAction(UIAlertAction(title: "Dismiss",
                                       style: .cancel))
    present(alertError, animated: true)
  }
  
  @objc private func didTapRegisterButton() {
    let registerVC = RegisterViewController()
    navigationController?.pushViewController(registerVC, animated: true)
  }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == loginView.emailTextField {
      loginView.passwordTextField.becomeFirstResponder()
    }
    else if textField == loginView.passwordTextField {
      didTapLoginButton()
    }
    
    return true
  }
}

extension LoginViewController: LoginButtonDelegate {
  func loginButton(_ loginButton: FBLoginButton,
                   didCompleteWith result: LoginManagerLoginResult?,
                   error: Error?) {
    
    if let error = error {
      print(error.localizedDescription)
      return
    }
    
    guard let token = AccessToken.current?.tokenString else {
      return
    }
    
    let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                     parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                     tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)
    
    loginView.spinner.show(in: view)
    
    facebookRequest.start { _ , result, error in
      guard let result = result as? [String: Any], error == nil else {
        return
      }
      
      guard let firstName = result["first_name"] as? String,
            let lastName = result["last_name"] as? String,
            let email = result["email"] as? String,
            let picture = result["picture"] as? [String: Any],
            let data = picture["data"] as? [String: Any],
            let pictureUrl = data["url"] as? String else {
        return
      }
      
      UserDefaults.standard.setValue(email, forKey: "email")
      let name = firstName + " " + lastName
      UserDefaults.standard.setValue(name, forKey: "name")
      
      DataBaseManager.shared.userExists(with: email) { exists in
        if !exists {
          let chatUser = MessengerModel(firstName: firstName,
                                        lastName: lastName,
                                        email: email)
          
          DataBaseManager.shared.insertUser(with: chatUser) { success in
            if success {
              
              guard let url = URL(string: pictureUrl) else { return }
              
              URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data else {
                  return
                }
                
                let fileName = chatUser.profilePictureFileName
                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                  switch result {
                  case .success(let downloadUrl):
                    UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                  case .failure(let error):
                    print(error)
                  }
                }
              }.resume()
            }
          }
        }
      }
      
      let credential = FacebookAuthProvider.credential(withAccessToken: token)
      
      FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
        guard authResult != nil, error == nil else {
          if let error = error {
            print(error)
          }
          return
        }
        
        DispatchQueue.main.async {
          self?.loginView.spinner.dismiss(animated: true)
        }
        NotificationCenter.default.post(name: Notification.Name("LogIn"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("ProfileSetup"), object: nil)
        self?.navigationController?.dismiss(animated: true)
      }
    }
  }
  
  func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    
  }
}
