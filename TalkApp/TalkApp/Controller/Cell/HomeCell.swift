

import UIKit

class HomeCell: UITableViewCell {

    //MARK:- OUTLET
    @IBOutlet var RoundView: UIView!
    @IBOutlet var BaseView: UIView!
    @IBOutlet var btnProfileCheck: UIButton!
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblChat: UILabel!
    @IBOutlet var lblTime: UILabel!
    
    //MARK:- Private properties
    let UserID = UserManager().currentUserID() ?? ""
    
   //MARK: Public methods
   func set(_ conversation: ObjectConversation) {
     lblTime.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
     lblChat.text = conversation.lastMessage
     guard let id = conversation.userIDs.filter({$0 != UserID}).first else { return }
     let isRead = conversation.isRead[UserID] ?? true
     if !isRead {
       lblUserName.font = lblUserName.font.bold
       lblChat.font = lblChat.font.bold
       lblChat.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)//ThemeService.purpleColor
       lblTime.font = lblTime.font.bold
     }
     ProfileManager.shared.userData(id: id) {[weak self] profile in
       self?.lblUserName.text = profile?.username
       guard let urlString = profile?.profilePicLink else {
         self?.ProfileImage.image = UIImage(named: "profile pic")
         return
       }
       self?.ProfileImage.setImage(url: URL(string: urlString))
       self!.ProfileImage.layer.borderWidth = 1.5
       self!.ProfileImage.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
       self!.ProfileImage.clipsToBounds = true
     }
   }
    
  //MARK: Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    ProfileImage.cancelDownload()
    lblUserName.font = lblUserName.font.regular
    lblChat.font = lblChat.font.regular
    lblTime.font = lblTime.font.regular
    lblChat.textColor = .gray
    lblChat.text = nil
  }
}
