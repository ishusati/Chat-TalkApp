

import UIKit

protocol KeyboardHandler: UIViewController {
  var barBottomConstraint: NSLayoutConstraint! { get }
  var bottomInset: CGFloat { get }
}

extension KeyboardHandler {
  func addKeyboardObservers(_ completion: CompletionObject<Bool>? = nil) {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) {[weak self] (notification) in
      self?.handleKeyboard(notification: notification)
      completion?(true)
    }
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) {[weak self] (notification) in
      self?.handleKeyboard(notification: notification)
      completion?(false)
    }
  }
  
  private func handleKeyboard(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
    barBottomConstraint.constant = notification.name == UIResponder.keyboardWillHideNotification ? 0 : keyboardFrame.height - view.safeAreaInsets.bottom
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}
