


import UIKit

class ContactCell: UICollectionViewCell {
    
    @IBOutlet var BaseView: UIView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var ProfilePic: UIImageView!
    
    
    override func prepareForReuse() {
      super.prepareForReuse()
      ProfilePic.cancelDownload()
      ProfilePic.image = UIImage(named: "profile pic")
        
        ProfilePic.layer.borderWidth = 1.5
        ProfilePic.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
        ProfilePic.clipsToBounds = true
    }
    
   func set(_ user: ObjectUser) {
     lblUserName.text = user.username
     if let urlString = user.profilePicLink {
        ProfilePic.setImage(url: URL(string: urlString))
        ProfilePic.layer.borderWidth = 1.5
        ProfilePic.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
        ProfilePic.clipsToBounds = true
     }
   }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      ProfilePic.layer.cornerRadius = (bounds.width - 10) / 2
    }
}
