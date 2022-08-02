//
//  LoginView.swift
//  Messenger
//
//  Created by Victor Vieira on 24/05/22.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginView: UIView {
  let spinner = JGProgressHUD(style: .dark)
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.clipsToBounds = true
    return scrollView
  }()
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "logo")
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let emailTextField: UITextField = {
    let textField = UITextField()
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.returnKeyType = .continue
    textField.layer.cornerRadius = 12
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.lightGray.cgColor
    textField.placeholder = "Email Address"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    textField.leftViewMode = .always
    textField.backgroundColor = .secondarySystemBackground
    return textField
  }()
  
  let passwordTextField: UITextField = {
    let textField = UITextField()
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.returnKeyType = .continue
    textField.layer.cornerRadius = 12
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.lightGray.cgColor
    textField.placeholder = "Password"
    textField.isSecureTextEntry = true
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    textField.leftViewMode = .always
    textField.backgroundColor = .secondarySystemBackground

    return textField
  }()
  
  let loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Log in", for: .normal)
    button.backgroundColor = UIColor(red: 25/255, green: 137/255, blue: 1, alpha: 1)
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let facebookLoginButton: FBLoginButton = {
    let facebookButton = FBLoginButton()
    facebookButton.translatesAutoresizingMaskIntoConstraints = false
    facebookButton.permissions = ["public_profile", "email"]
    return facebookButton
  }()
  
  let googleLoginButton: GIDSignInButton = {
    let googleButton = GIDSignInButton()
    googleButton.translatesAutoresizingMaskIntoConstraints = false
    return googleButton
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
    addSubview(scrollView)
    scrollView.addSubview(logoImageView)
    scrollView.addSubview(emailTextField)
    scrollView.addSubview(passwordTextField)
    scrollView.addSubview(loginButton)
    scrollView.addSubview(facebookLoginButton)
    scrollView.addSubview(googleLoginButton)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

      logoImageView.widthAnchor.constraint(equalToConstant: 80),
      logoImageView.heightAnchor.constraint(equalToConstant: 80),
      logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
      logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      
      emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
      emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      emailTextField.heightAnchor.constraint(equalToConstant: 50),
      
      passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
      passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      passwordTextField.heightAnchor.constraint(equalToConstant: 50),
      
      loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
      loginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      loginButton.heightAnchor.constraint(equalToConstant: 50),
      
      facebookLoginButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30),
      facebookLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      facebookLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      
      googleLoginButton.topAnchor.constraint(equalTo: facebookLoginButton.bottomAnchor, constant: 30),
      googleLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      googleLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50)
    ])
  }
}
