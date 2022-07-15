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
  
  public func uploadProfilePicture(with data: Data,
                                   fileName: String,
                                   completion: @escaping UploadPictureCompletion) {
    
    storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
      
      guard error == nil else {
        print("Failed to upload image")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }

      self?.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
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
  
  public func uploadMessagePhoto(with data: Data,
                                 fileName: String,
                                 completion: @escaping UploadPictureCompletion) {
    
    storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
      
      guard error == nil else {
        print("Failed to upload image")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }

      self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
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
  
  public func uploadMessageVideo(with fileUrl: URL,
                                 fileName: String,
                                 completion: @escaping UploadPictureCompletion) {
    
    storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) { [weak self] metaData, error in
      
      guard error == nil else {
        print("Failed to upload video")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }

      self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
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
  
  
  public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let reference = storage.child(path)

    reference.downloadURL { url, error in
      guard let url = url, error == nil else {
        completion(.failure(StorageErrors.failedToGetDownloadUrl))
        return
      }
      completion(.success(url))
    }
  }
}

public enum StorageErrors: Error {
  case failedToUpload
  case failedToGetDownloadUrl
}
