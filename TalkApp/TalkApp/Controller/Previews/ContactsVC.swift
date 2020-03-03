
import UIKit
import Firebase

class ContactsVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet var ColleContact: UICollectionView!
    
    //MARK:- VARIABLE
    weak var delegate: ContactsPreviewControllerDelegate?
    private var users = [ObjectUser]()
    private let manager = UserManager()
    
    var arrIsActiveData = [IsActiveData]()
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        self.IsActiveDataGet()
       guard let id = manager.currentUserID() else { return }
       manager.contacts {[weak self] results in
         self?.users = results.filter({$0.id != id})
         self?.ColleContact.reloadData()
       }
        
        if (Reachability.isConnectedToNetwork() == true)
        {
          AudioService().playSound()
        }
        else
        {
            let net = appDelegate.InternetConnectionErrorApp(view: self.view)
            net.isUserInteractionEnabled = true
            net.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeNetView)))
        }
     }
    
    @objc func removeNetView()
    {
        if(Reachability.isConnectedToNetwork() == true)
        {
            appDelegate.RemoveNetworkLostView()
        }
        else
        {
            print("*******************************-: Network Reachability Error :-*******************************")
               //appDelegate.RemoveNetworkLostView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       modalTransitionStyle = .crossDissolve
       modalPresentationStyle = .overFullScreen
     }
    
    //MARK:- ACTION
    @IBAction func btnClose(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- TABLEVIEW DELEGET & DATASOURCE
extension ContactsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard !users.isEmpty else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.className, for: indexPath) as! ContactCell
    cell.BaseView.layer.cornerRadius = cell.BaseView.frame.height/2
    cell.BaseView.layer.borderWidth = 1.5
    cell.BaseView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.BaseView.isHidden = true
    
    let id = users[indexPath.row].id
    print("id\(id)")
    for i in 0..<arrIsActiveData.count
    {
        let Data = arrIsActiveData[i]
        let UserIddd = Data.UserID
        let isActi = Data.isActive
         print(isActi as Any)
        if isActi == "Yes"
        {
            if id == UserIddd
            {
                cell.BaseView.isHidden = false
                print("UserIddd \(UserIddd ?? "")")
            }
        }
        
    }
    
    cell.set(users[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
     let userID = Auth.auth().currentUser!.uid
     let id = users[indexPath.row].id
    
    let ref = Database.database().reference(withPath: "BlockUser")
    ref.child(userID+id).observeSingleEvent(of: .value, with: { (snapshot) in
       
       let value = snapshot.value as? NSDictionary
            
       if value != nil
       {
           appDelegate.showToast(title: "Block", message: "This User Are Block", ImageName: "error")
       }
       else
       {
          ref.child(id+userID).observeSingleEvent(of: .value, with: { (snapshot) in
           
           let value = snapshot.value as? NSDictionary
                       
           if value != nil
           {
               appDelegate.showToast(title: "Block", message: "This User You Block", ImageName: "error")
           }
           else
           {
              guard !self.users.isEmpty else { return }
               self.dismiss(animated: true) {
                   self.delegate?.contactsPreviewController(didSelect: self.users[indexPath.row])
               }
           }
           
           })
           { (error) in
                       print(error.localizedDescription)
           }
       }
           }) { (error) in
                   print(error.localizedDescription)
       }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard !users.isEmpty else {
      return collectionView.bounds.size
    }
    let width = (collectionView.bounds.width - 35) / 3 //spacing
    return CGSize(width: width, height: width + 25)
  }
}


//MARK:- DELEGET & PROTICOL
protocol ContactsPreviewControllerDelegate: class {
  func contactsPreviewController(didSelect user: ObjectUser)
}

extension ContactsVC
{
  func IsActiveDataGet()
  {
     let ref = Database.database().reference().child("IsOnline")
     ref.observe(.childAdded, with: { snapshot in
        let dict = snapshot.value as! [String: Any]
        let UserId = dict["UserId"] as? String ?? ""
        let IsActive = dict["IsActive"] as? String ?? ""
        
        let userIDmy = Auth.auth().currentUser!.uid
        if UserId == userIDmy
        {
            
        }
        else
        {
            self.arrIsActiveData.insert(IsActiveData(isActive: IsActive, UserID: UserId), at: 0)
            self.ColleContact.reloadData()
        }
        
    })
  }
}
