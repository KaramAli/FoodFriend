//
//  Storage.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import Foundation
import FirebaseStorage

// a class to access the storage of firebase where the images are saved to
final class StorageManager {
    static let storageManager = StorageManager()
    
    private let storageReference = Storage.storage().reference()
    
    //for a given path this function will return the image url
    public func retrieveURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let pathReference = storageReference.child(path)
        //download image url from path
        pathReference.downloadURL(completion: { url, error in
            guard let imageUrl = url, error == nil else {
                // any errors or imageUrl does not = to url then come here
                completion(.failure(Errors.downloadFailed))
                return
            }
            //completion is success if returned with an imageURL
            completion(.success(imageUrl))
        })
    }
    
    // the function dedicated to storing profile images
    public func storeProfileImage(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void){
        //in storage under images store image under given file name
        storageReference.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, results in
            guard results == nil else {
                completion(.failure(Errors.uploadFailed))
                return
            }
            self.storageReference.child("images/\(fileName)").downloadURL(completion: {photoUrl, error in
                guard let photoUrl = photoUrl else {
                    completion(.failure(Errors.downloadFailed))
                    return
                }
                let urlData = photoUrl.absoluteString
                completion(.success(urlData))
            })
        })
        
    }
    // this function
    public func storeDiaryImages(with data: Data, fileName: String, completion:
        @escaping (Result<String, Errors>) -> Void){
        storageReference.child("diaryImages/\(fileName)").putData(data, metadata: nil, completion: {metadata, results in
            guard results == nil else {
                completion(.failure(Errors.uploadFailed))
                return
            }
            self.storageReference.child("diaryImages/\(fileName)").downloadURL(completion: {photoUrl, error in
                guard let photoUrl = photoUrl else {
                    completion(.failure(Errors.downloadFailed))
                    return
                }
                let urlData = photoUrl.absoluteString
                completion(.success(urlData))
            })
        })
    }
    // function to download image url
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let ref = storageReference.child(path)
        //from path under ref
        ref.downloadURL(completion: {urlPhoto, error in
            guard error == nil, let url = urlPhoto else {
                //any errors or url does not equal urlPhoto data from firebase
                completion(.failure(Errors.downloadFailed))
                return
            }
            // if urlPhoto is successfully obtained from path
            completion(.success(url))
        })
    }
    //MARK: Error Manager
    public enum Errors: Error {
        case uploadFailed
        case downloadFailed
    }
}
