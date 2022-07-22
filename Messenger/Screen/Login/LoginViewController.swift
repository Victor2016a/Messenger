//
//  LoginViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit

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
    loginView.emailTextField.delegate = self
    loginView.passwordTextField.delegate = self
  }
  
  @objc private func didTapLoginButton() {
    loginView.emailTextField.resignFirstResponder()
    loginView.passwordTextField.resignFirstResponder()
    
    guard let email = loginView.emailTextField.text, let password = loginView.passwordTextField.text,
          !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
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
