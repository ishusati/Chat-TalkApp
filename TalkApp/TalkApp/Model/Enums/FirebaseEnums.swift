

import Foundation

public enum FirestoreCollectionReference: String {
  case users = "Users"
  case conversations = "Conversations"
  case messages = "Messages"
  case StatusImage = "StatusImage"
}

public enum FirestoreResponse {
  case success
  case failure
}
