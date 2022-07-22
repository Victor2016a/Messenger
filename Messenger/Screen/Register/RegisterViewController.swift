//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit

class RegisterViewController: UIViewController {
  let registerView = RegisterView()
  
  override func loadView() {
    super.loadView()
    view = registerView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = .systemBackground
    title = "Create Account"
    
    registerView.registerButton.addTarget(self,
                                          action: #selector(didTapRegisterButton),
                                          for: .touchUpInside)
    
    let gesture = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapProfileImage))
    registerView.profileImageView.isUserInteractionEnabled = true
    registerView.profileImageView.addGestureRecognizer(gesture)
    
    registerView.firstNameTextField.delegate = self
    registerView.lastNameTextField.delegate = self
    registerView.emailTextField.delegate = self
    registerView.passwordTextField.delegate = self
  }
  
  @objc private func didTapProfileImage() {
    presentPhotoActionSheet()
  }
  
  @objc private func didTapRegisterButton() {
    registerView.firstNameTextField.resignFirstResponder()
    registerView.lastNameTextField.resignFirstResponder()
    registerView.emailTextField.resignFirstResponder()
    registerView.passwordTextField.resignFirstResponder()
    
    guard let firstName = registerView.firstNameTextField.text,
          let lasteName = registerView.lastNameTextField.text,
          let email = registerView.emailTextField.text,
          let password = registerView.passwordTextField.text,
          !firstName.isEmpty,
          !lasteName.isEmpty,
          !email.isEmpty,
          !password.isEmpty,
          password.count >= 6 else {
            alertUserLoginError()
            return
          }
  }

  private func alertUserLoginError() {
    let alertError = UIAlertController(title: "Whoops!",
                                       message: "Please, enter all information to create a new account.",
                                       preferredStyle: .alert)
    
    alertError.addAction(UIAlertAction(title: "Dismiss",
                                       style: .cancel))
    present(alertError, animated: true)
  }
}

extension RegisterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == registerView.firstNameTextField {
      registerView.lastNameTextField.becomeFirstResponder()
      
    } else if textField == registerView.lastNameTextField {
      registerView.emailTextField.becomeFirstResponder()
      
    } else if textField == registerView.emailTextField {
      registerView.passwordTextField.becomeFirstResponder()
      
    } else if textField == registerView.passwordTextField {
      didTapRegisterButton()
    }
    return true
  }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func presentPhotoActionSheet() {
    let actionSheet = UIAlertController(title: "Profile Picture",
                                        message: "How would you like to select a picture?",
                                        preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: nil))
    
    actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                        style: .default,
                                        handler: { [weak self] _ in
                                        self?.presentCamera()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                        style: .default,
                                        handler: { [weak self] _ in
                                        self?.presentPhotoPicker()
    }))
    
    present(actionSheet, animated: true)
  }
  
  func presentCamera() {
    let pickerController = UIImagePickerController()
    pickerController.sourceType = .camera
    pickerController.allowsEditing = true
    pickerController.delegate = self
    present(pickerController, animated: true)
  }
  
  func presentPhotoPicker() {
    let pickerController = UIImagePickerController()
    pickerController.sourceType = .photoLibrary
    pickerController.allowsEditing = true
    pickerController.delegate = self
    present(pickerController, animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    
    guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    
    registerView.profileImageView.image = selectedImage
    registerView.profileImageView.layer.cornerRadius = registerView.profileImageView.bounds.width/2
    registerView.profileImageView.layer.borderWidth = 1.5
    registerView.profileImageView.layer.borderColor = UIColor.lightGray.cgColor
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
