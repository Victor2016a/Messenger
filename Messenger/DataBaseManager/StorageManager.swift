//
//  StorageManager.swift
//  Messenger
//
//  Created by Victor Vieira on 15/06/22.
//

import Foundation
import FirebaseStorage

final class StorageManager {
  
  static let shared = StorageManager()
  
  private let storage = Storage.storage().reference()
  
  public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
  
  public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
    
    storage.child("images\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
      
      guard error == nil else {
        print("Failed to upload image")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self?.storage.child("images\(fileName)").downloadURL(completion: { url, error in
        guard let url = url else {
          print("Failed to get url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        
        let urlString = url.absoluteString
        print("Download url returned: \(urlString)")
        completion(.success(urlString))
      })
    }
  }
}

public enum StorageErrors: Error {
  case failedToUpload
  case failedToGetDownloadUrl
}
