//
//  ProfileModel.swift
//  Messenger
//
//  Created by Victor Vieira on 27/07/22.
//

import Foundation

struct ProfileModel {
  let modelType: ProfileModelType
  let title: String
  let handler: (() -> Void)?
}

enum ProfileModelType {
  case logout
}
