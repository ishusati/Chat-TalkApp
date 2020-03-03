


import UIKit

class FriendChatVC: UIViewController {

    @IBOutlet var FriendChatColle: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    @IBAction func btnClose(_ sender: Any)
    {
      self.dismiss(animated: true, completion: nil)
    }
}


extension FriendChatVC : UICollectionViewDelegate,UICollectionViewDataSource
{
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
       {
          return 10
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendColle", for: indexPath) as! FriendColle
           
        cell.ImageProfile.layer.cornerRadius = cell.ImageProfile.frame.height/2
        cell.ImageProfile.clipsToBounds = true
        cell.BaseView.layer.cornerRadius = cell.BaseView.frame.height/2
        cell.clipsToBounds = true
        
        cell.BaseView.layer.borderWidth = 1.5
        cell.BaseView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.ImageProfile.image = UIImage(named: "Profile")
        cell.lblUserName.text = "jsdkjasdh"
        
        return cell
               
    }
}

extension FriendChatVC : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
       return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
       {
         return 10
       }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
       {
         return 30
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
       return UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 40)
    }

}

