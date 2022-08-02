//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit
import FirebaseAuth

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
          let lastName = registerView.lastNameTextField.text,
          let email = registerView.emailTextField.text,
          let password = registerView.passwordTextField.text,
          !firstName.isEmpty,
          !lastName.isEmpty,
          !email.isEmpty,
          !password.isEmpty,
          password.count >= 6 else {
            alertUserLoginError()
            return
          }
    
    UserDefaults.standard.setValue(email, forKey: "email")
    let name = firstName + " " + lastName
    UserDefaults.standard.setValue(name, forKey: "name")
    
    registerView.spinner.show(in: view)
    
    DataBaseManager.shared.userExists(with: email) { [weak self] exists in
      guard !exists else {
        self?.alertUserLoginError(message: "Looks like a user account for that email address alredy exists")
        return
      }
      
      FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                          password: password) { [weak self] authResult, error in
        
        guard authResult != nil, error == nil else {
          return
        }
                
        let chatUser = MessengerModel(firstName: firstName,
                                      lastName: lastName,
                                      email: email)
        
        DataBaseManager.shared.insertUser(with: chatUser) { success in
          if success {
            guard let image = self?.registerView.profileImageView.image,
                    let data = image.pngData() else {
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
          }
        }
        
        DispatchQueue.main.async {
          self?.registerView.spinner.dismiss(animated: true)
        }
        
        self?.navigationController?.dismiss(animated: true)
      }
    }
  }

  private func alertUserLoginError(message: String = "Please, enter all information to create a new account.") {
    let alertError = UIAlertController(title: "Whoops!",
                                       message: message,
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
