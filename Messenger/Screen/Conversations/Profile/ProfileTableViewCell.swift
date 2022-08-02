//
//  ProfileTableViewCell.swift
//  Messenger
//
//  Created by Victor Vieira on 27/07/22.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
  static let identifier = "ProfileTableViewCell"
  
  func configure(with profileModel: ProfileModel) {
    self.textLabel?.text = profileModel.title
    
    switch profileModel.modelType {
    case .logout:
      self.textLabel?.textAlignment = .center
      self.textLabel?.textColor = .red
    }
  }
}
