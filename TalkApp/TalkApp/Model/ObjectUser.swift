

import UIKit

class ObjectUser: FireStorageCodable {
  
  var id = UUID().uuidString
  var username: String?
  var email: String?
  var profilePicLink: String?
  var profilePic: UIImage?
  var password: String?
  var mobilenumber: String?

  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(username, forKey: .username)
    try container.encodeIfPresent(email, forKey: .email)
    try container.encodeIfPresent(profilePicLink, forKey: .profilePicLink)
    try container.encodeIfPresent(mobilenumber, forKey: .mobilenumber)

  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    username = try container.decodeIfPresent(String.self, forKey: .username)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    profilePicLink = try container.decodeIfPresent(String.self, forKey: .profilePicLink)
    mobilenumber = try container.decodeIfPresent(String.self, forKey: .mobilenumber)
    
  }
}

extension ObjectUser {
  private enum CodingKeys: String, CodingKey {
    case id
    case email
    case username
    case profilePicLink
    case mobilenumber
  }
}
