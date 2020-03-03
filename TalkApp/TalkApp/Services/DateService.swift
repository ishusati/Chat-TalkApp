

import Foundation

class DateService {
  
  static let shared = DateService()
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
  }()
  
  private init() {}
  
  func format(_ date: Date) -> String {
    return dateFormatter.string(from: date)
  }
}
