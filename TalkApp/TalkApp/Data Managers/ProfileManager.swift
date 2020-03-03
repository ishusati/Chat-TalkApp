

import Foundation

class ProfileManager {
  
  static let shared = ProfileManager()
  private var users = [ObjectUser]()
  
  func userData(id: String, _ completion: @escaping CompletionObject<ObjectUser?>) {
    if let user = users.filter({$0.id == id}).first {
      completion(user)
      return
    }
    let query = FirestoreService.DataQuery(key: "id", value: id, mode: .equal)
    FirestoreService().objects(ObjectUser.self, reference: .init(location: .users), parameter: query) {[weak self] results in
      guard let user = results.first else {
        completion(nil)
        return
      }
      self?.users.append(user)
      completion(user)
    }
  }
  
  private init() {}
}
