

import Foundation
import CoreLocation

extension String {
  
  func isValidEmail() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
    
    func isValidPassword() -> Bool {
    let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,100}$"
    return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
}
    
  var location: CLLocationCoordinate2D? {
    let coordinates = self.components(separatedBy: ":")
    guard coordinates.count == 2 else { return nil }
    return CLLocationCoordinate2D(latitude: Double(coordinates.first!)!, longitude: Double(coordinates.last!)!)
  }
}
