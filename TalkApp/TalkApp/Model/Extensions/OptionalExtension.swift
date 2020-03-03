

import Foundation
import UIKit

extension Optional {
  var isNone: Bool {
    return self == nil
  }
  
  var isSome: Bool {
    return self != nil
  }
}


extension Encodable {
  var values: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension NSObject {
  class var className: String {
    return String(describing: self.self)
  }
}

extension UIViewController {
  
  func showAlert(title: String = "Error", message: String = "Something went wrong", completion: EmptyCompletion? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
      completion?()
    }))
    present(alert, animated: true, completion: nil)
  }
}

extension UITableView {
  
  func scroll(to: Position, animated: Bool) {
    let sections = numberOfSections
    let rows = numberOfRows(inSection: numberOfSections - 1)
    switch to {
    case .top:
      if rows > 0 {
        let indexPath = IndexPath(row: 0, section: 0)
        self.scrollToRow(at: indexPath, at: .top, animated: animated)
      }
      break
    case .bottom:
      if rows > 0 {
        let indexPath = IndexPath(row: rows - 1, section: sections - 1)
        self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
      }
      break
    }
  }
  
  enum Position {
    case top
    case bottom
  }
}


extension UIStoryboard {
  
  class func controller<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateViewController(withIdentifier: T.className) as! T
  }
  
  class func initial<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateInitialViewController() as! T
  }
  
  enum StoryboardEnum: String {
    case SignUpSignIn = "SignUpSignIn"
    case Home = "Home"
    case Profile = "Profile"
    case Previews = "Previews"
    case Messages = "Message"
  }
}


extension UIFont {
  
  var bold: UIFont {
    return with(traits: .traitBold)
  }
  
  var regular: UIFont {
    var fontAtrAry = fontDescriptor.symbolicTraits
    fontAtrAry.remove([.traitBold])
    let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
    return UIFont(descriptor: fontAtrDetails!, size: pointSize)
  }
  
  func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
      return self
    }
    return UIFont(descriptor: descriptor, size: 0)
  }
}

extension Dictionary {
  
  var data: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
  }
}
