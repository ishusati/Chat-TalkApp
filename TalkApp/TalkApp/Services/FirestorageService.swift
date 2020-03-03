
import FirebaseStorage
import UIKit

class FirestorageService {
  
  func update<T>(_ object: T, reference: FirestoreCollectionReference, completion: @escaping CompletionObject<FirestoreResponse>) where T: FireStorageCodable {
    
    guard let imageData = object.profilePic?.scale(to: CGSize(width: 350, height: 350))?.jpegData(compressionQuality: 0.3) else { completion(.success); return }
    
    
    let ref = Storage.storage().reference().child(reference.rawValue).child(object.id).child(object.id + ".jpg")
    
    let uploadMetadata = StorageMetadata()
    uploadMetadata.contentType = "image/jpg"
    
    ref.putData(imageData, metadata: uploadMetadata) { (_, error) in
      guard error.isNone else { completion(.failure); return }
      ref.downloadURL(completion: { (url, err) in
        if let downloadURL = url?.absoluteString {
          object.profilePic = nil
          object.profilePicLink = downloadURL
          completion(.success)
          return
        }
        completion(.failure)
      })
    }
  }
}
