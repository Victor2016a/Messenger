//
//  RegisterView.swift
//  Messenger
//
//  Created by Victor Vieira on 25/05/22.
//

import UIKit

class RegisterView: UIView {
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.clipsToBounds = true
    return scrollView
  }()
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "person.circle")
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let firstNameTextField: UITextField = {
    let textField = UITextField()
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.returnKeyType = .continue
    textField.layer.cornerRadius = 12
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.lightGray.cgColor
    textField.placeholder = "First Name"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    textField.leftViewMode = .always
    textField.backgroundColor = .secondarySystemBackground
    return textField
  }()
  
  let lastNameTextField: UITextField = {
    let textField = UITextField()
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.returnKeyType = .continue
    textField.layer.cornerRadius = 12
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.lightGray.cgColor
    textField.placeholder = "Last Name"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    textField.leftViewMode = .always
    textField.backgroundColor = .secondarySystemBackground
    return textField
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
  
  let registerButton: UIButton = {
    let button = UIButton()
    button.setTitle("Register", for: .normal)
    button.backgroundColor = UIColor.systemGreen
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
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
    scrollView.addSubview(profileImageView)
    scrollView.addSubview(firstNameTextField)
    scrollView.addSubview(lastNameTextField)
    scrollView.addSubview(emailTextField)
    scrollView.addSubview(passwordTextField)
    scrollView.addSubview(registerButton)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

      profileImageView.widthAnchor.constraint(equalToConstant: 140),
      profileImageView.heightAnchor.constraint(equalToConstant: 140),
      profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
      profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      
      firstNameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30),
      firstNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      firstNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      firstNameTextField.heightAnchor.constraint(equalToConstant: 50),
      
      lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
      lastNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      lastNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      lastNameTextField.heightAnchor.constraint(equalToConstant: 50),
      
      emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 10),
      emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      emailTextField.heightAnchor.constraint(equalToConstant: 50),
      
      passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
      passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      passwordTextField.heightAnchor.constraint(equalToConstant: 50),
      
      registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
      registerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
      registerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
      registerButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
}
