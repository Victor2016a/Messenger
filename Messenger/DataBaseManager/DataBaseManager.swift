//
//  DataBaseManager.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import Foundation
import FirebaseDatabase

final class DataBaseManager {
  static let shared = DataBaseManager()
  private let database = Database.database().reference()
}

extension DataBaseManager {
  public func emailExists(with email: String, completion: @escaping ((Bool) -> Void)) {
    
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    
    database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
      guard snapshot.value as? String != nil else {
        completion(false)
        return
      }
      completion(true)
    }
  }
  
  public func insertUser(with user: MessengerModel) {
    database.child(user.safeEmail).setValue([
      "firstName": user.firstName,
      "lastName": user.lastName
    ])
  }
}
