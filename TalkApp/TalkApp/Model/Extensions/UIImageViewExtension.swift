

import UIKit
import Kingfisher

extension UIImageView {
  
  func setImage(url: URL?, completion: CompletionObject<UIImage?>? = nil) {
    kf.setImage(with: url) { result in
      switch result {
      case .success(let value):
        completion?(value.image)
      case .failure(_):
        completion?(nil)
      }
    }
  }
  
  func cancelDownload() {
    kf.cancelDownloadTask()
  }
}

extension UIImage {
  
  func fixOrientation() -> UIImage {
    if (imageOrientation == .up) { return self }
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    draw(in: rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
  
  func scale(to newSize: CGSize) -> UIImage? {
    let horizontalRatio = newSize.width / size.width
    let verticalRatio = newSize.height / size.height
    let ratio = max(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}

