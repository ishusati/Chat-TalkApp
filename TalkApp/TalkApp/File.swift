import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UploadImages: NSObject{

//static func saveImages(imagesArray : [UIImage]){
//
//        Auth.auth().signInAnonymously() { (, error) in
//            //let isAnonymous = user!.isAnonymous  // true
//            //let uid = user!.uid
//            if error != nil{
//                print(error as Any)
//                return
//            }
//            else
//            {
//                let userID = Auth.auth().currentUser!.uid
//
//                uploadImages(userId: userID,imagesArray : imagesArray){ (uploadedImageUrlsArray) in
//                    print("uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
//            }
//
//            }
//        }
//    }


static func uploadImagesss(userId: String, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
    let storage = Storage.storage()

    var uploadedImageUrlsArray = [String]()
    var uploadCount = 0
    let imagesCount = imagesArray.count

    for image in imagesArray{

        let imageName = NSUUID().uuidString // Unique string to reference image

        //Create storage reference for image
        let storageRef = storage.reference().child("\(userId)").child("\(imageName).png")

        guard let uplodaData = image.pngData() else{
            return
        }

        // Upload image to firebase
        let uploadTask = storageRef.putData(uplodaData, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                print(error as Any)
                return
            }
            else
            {
                storageRef.downloadURL(completion: { (url, error) in
                    if let StrUrl = url?.absoluteString
                    {
                        print("///////////tttttttt//////// \(StrUrl)   ////////")
                        uploadedImageUrlsArray.append(StrUrl)
                        uploadCount += 1
                        print("Number of images successfully uploaded: \(uploadCount)")

                        if uploadCount == imagesCount
                        {
                           print("All Images are uploaded successfully, uploadedImageUrlsArray:\(uploadedImageUrlsArray)")
                            completionHandler(uploadedImageUrlsArray)
                        }
                       

                        }
                    })
                
//                if let imageUrl = metadata?.downloadURL(){
//                    print(imageUrl)
//                    uploadedImageUrlsArray.append(imageUrl)
//
//                    uploadCount += 1
//                    print("Number of images successfully uploaded: \(uploadCount)")
//                    if uploadCount == imagesCount{
//                        NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
//                        completionHandler(uploadedImageUrlsArray)
//                    }
//                }
            }
        })


        observeUploadTaskFailureCases(uploadTask : uploadTask)
    }
}


//Func to observe error cases while uploading image files, Ref: https://firebase.google.com/docs/storage/ios/upload-files


    static func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
            switch (StorageErrorCode(rawValue: error.code)!) {
            case .objectNotFound:
              NSLog("File doesn't exist")
              break
            case .unauthorized:
              NSLog("User doesn't have permission to access file")
              break
            case .cancelled:
              NSLog("User canceled the upload")
              break

            case .unknown:
              NSLog("Unknown error occurred, inspect the server response")
              break
            default:
              NSLog("A separate error occurred, This is a good place to retry the upload.")
              break
            }
          }
        }
    }

}


































