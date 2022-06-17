//
//  MessengerModel.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import Foundation

struct MessengerModel {
  var firstName: String
  var lastName: String
  var email: String
  
  var safeEmail: String {
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
  
  var profilePictureFileName: String {
    return "\(safeEmail)_profile_picture.png"
  }
}
