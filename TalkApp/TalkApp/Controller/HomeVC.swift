

import UIKit
import Firebase
import FirebaseStorage
import CallKit



class HomeVC: UIViewController {
    
    //MARK:- OUTLET
    @IBOutlet var tblHome: UITableView!
    
    @IBOutlet var btnCall: UIButton!
    @IBOutlet var FrindProfilePic: UIImageView!
    @IBOutlet var lblFriendName: UILabel!
    @IBOutlet var lblFriendEmail: UILabel!
    @IBOutlet var lblFriendMobileNu: UILabel!
    @IBOutlet var FriendViewAnimationContraint: NSLayoutConstraint!
    
    @IBOutlet var FriendView: UIView!
    @IBOutlet var btnVideoCall: UIButton!
    //MARK:- VARIABLE
    private var ConversationsMesaage = [ObjectConversation]()
    private var UserData: ObjectUser?
    private let DataManager = ConversationManager()
    private let userManager = UserManager()
    
    var BlockID = String()
    var BlockDeleteID = String()
    var arrIsActiveData = [IsActiveData]()
    
    var MobileNumber = String()
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tblHome.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tblHome.tableFooterView = UIView()
        
        self.FriendView.layer.cornerRadius = 13
        self.btnVideoCall.layer.cornerRadius = 15
        self.btnCall.layer.cornerRadius = 15
        self.FrindProfilePic.layer.cornerRadius = self.FrindProfilePic.frame.height/2
        self.FrindProfilePic.clipsToBounds = true
    }
    
    //MARK:- STATUSBAR
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .default
    }
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
           
        if (Reachability.isConnectedToNetwork() == true)
        {
            self.FetchProfile()
            self.FetchConversationsMessage()
             AudioService().playSound()
            self.IsActiveDataGetDark()
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
    
    //MARK:- ACTION
    @IBAction func btnFriendViewClose(_ sender: Any)
    {
        FriendViewAnimationContraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
         })
    }
    @IBAction func btnVideoCall(_ sender: Any)
    {
        if self.btnVideoCall.currentTitle == "Block"
        {
            let ref = Database.database().reference()
            let userID = Auth.auth().currentUser!.uid //childByAutoId()
            guard let key = ref.child("BlockUser").child(userID+self.BlockID).key else { return }
            let param = ["Owner_ID": userID ,"Friend_ID": self.BlockID]
            let childUpdates = ["/BlockUser/\(key)": param ]
            ref.updateChildValues(childUpdates)
            self.btnVideoCall.setTitle("UnBlock", for: .normal)
            appDelegate.showToast(title: "Block", message: "This User Are Block", ImageName: "sucessAlert")
        }
        else
        {
          
          FirebaseDatabase.Database.database().reference(withPath: "BlockUser").child(BlockDeleteID).setValue(nil)
             appDelegate.showToast(title: "BlockUn", message: "This User Are UnBlock", ImageName: "sucessAlert")
          self.btnVideoCall.setTitle("Block", for: .normal)
        }
    }
    
    @IBAction func btnCall(_ sender: Any)
    {
      let charsToRemove: Set<Character> = Set("()+-")
      let newNumberCharacters = String(self.MobileNumber.filter { !charsToRemove.contains($0) })
      print("Space Mobile No:- \(newNumberCharacters)")
    
        if let phoneCallURL = URL(string: "tel://\(newNumberCharacters)")
        {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL))
            {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
}


//MARK: Private methods
extension HomeVC {
  
  func FetchConversationsMessage() {
    DataManager.currentConversations {[weak self] conversations in
      self?.ConversationsMesaage = conversations.sorted(by: {$0.timestamp > $1.timestamp})
      self?.tblHome.reloadData()
      self?.playSoundIfNeeded()
    }
  }
  
  func FetchProfile() {
    userManager.currentUserData {[weak self] user in
      self?.UserData = user
      if let urlString = user?.profilePicLink {
     //self?.setImage(url: URL(string: urlString))
      }
    }
  }
  
  func playSoundIfNeeded() {
    guard let id = userManager.currentUserID() else { return }
    if ConversationsMesaage.last?.isRead[id] == false {
      AudioService().playSound()
    }
  }
    
    func GetBlockData()
    {
        let userID = Auth.auth().currentUser!.uid
        
       let ref = Database.database().reference().child("BlockUser")
       ref.observe(.childAdded, with: { snapshot in
          let dict = snapshot.value as! [String: Any]
          let Owner_ID = dict["Owner_ID"] as? String ?? ""
          let Friend_ID = dict["Friend_ID"] as? String ?? ""
          let key = snapshot.key
          print("owner_ID:- \(Owner_ID),Friend_ID:- \(Friend_ID),key \(key)")
        
          if userID == Owner_ID && self.BlockID == Friend_ID
          {
            self.btnVideoCall.setTitle("UnBlock", for: .normal)
            self.BlockDeleteID = snapshot.key
          }
          else if self.BlockID == Owner_ID && userID == Friend_ID
          {
             self.btnVideoCall.setTitle("Block", for: .normal)
          }
      })
    }
}

//MARK:- TABLEVIEW METHOD
extension HomeVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ConversationsMesaage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       let cell = tableView.dequeueReusableCell(withIdentifier: HomeCell.className) as! HomeCell
        
        cell.BaseView.layer.cornerRadius = 10
        cell.BaseView.layer.borderWidth = 1.5
        cell.BaseView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        cell.ProfileImage.layer.cornerRadius = cell.ProfileImage.frame.height/2
        cell.clipsToBounds = true
        
        cell.selectionStyle = .none
        cell.btnProfileCheck.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        cell.btnProfileCheck.tag = indexPath.row

        cell.RoundView.layer.cornerRadius = cell.RoundView.frame.height/2
        cell.RoundView.layer.borderWidth = 0.8
        cell.RoundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.RoundView.isHidden = true
        
       let UserID = UserManager().currentUserID() ?? ""
       let data = ConversationsMesaage[indexPath.row]
       let id = data.userIDs.filter({$0 != UserID}).first
       print("id \(id ?? "")")
        
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
                    cell.RoundView.isHidden = false
                    print("UserIddd \(UserIddd ?? "")")
                }
            }
            
        }
        cell.set(ConversationsMesaage[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
      let userID = Auth.auth().currentUser!.uid
      let UserID = UserManager().currentUserID() ?? ""
      let data = ConversationsMesaage[indexPath.row]
      guard let id = data.userIDs.filter({$0 != UserID}).first else { return }
        
        let currentCell = tableView.cellForRow(at: indexPath) as! HomeCell

        
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
                let vc: MessageVC = UIStoryboard.initial(storyboard: .Messages)
                if currentCell.RoundView.isHidden == false
                {
                  vc.IsActive = "Active"
                }
                else
                {
                  vc.IsActive = "NotActive"
                }
                
                vc.conversation = self.ConversationsMesaage[indexPath.row]
                self.DataManager.markAsRead(self.ConversationsMesaage[indexPath.row])
                self.show(vc, sender: self)
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
    
   @objc func connected(sender: UIButton)
   {
    
    let UserID = UserManager().currentUserID() ?? ""
    let data = ConversationsMesaage[sender.tag]
    guard let id = data.userIDs.filter({$0 != UserID}).first else { return }
    self.BlockID = id

    ProfileManager.shared.userData(id: id) {[weak self] profile in
        self?.lblFriendName.text = "UserName: \(profile?.username ?? "")"
        self?.lblFriendMobileNu.text = "Phone: \(profile?.mobilenumber ?? "")"
        self?.lblFriendEmail.text = "Email: \(profile?.email ?? "")"
        self?.MobileNumber = "\(profile?.mobilenumber ?? "")"
        
      guard let urlString = profile?.profilePicLink else {
        self?.FrindProfilePic.image = UIImage(named: "profile pic")
        return
      }
      self?.FrindProfilePic.setImage(url: URL(string: urlString))
      self!.btnVideoCall.setTitle("Block", for: .normal)
      self?.GetBlockData()
        
        self!.FriendViewAnimationContraint.constant = -15
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
        self!.view.layoutIfNeeded()
      })
    }
   }
}

//MARK: ProfileViewController Delegate
extension HomeVC: ProfileViewControllerDelegate {
  func profileViewControllerDidLogOut() {
    userManager.logout()
    //self.navigationController?.popViewController(animated: true)
    
    
//    let vc: SignInVC = UIStoryboard.initial(storyboard: .SignUpSignIn)
//    present(vc, animated: true, completion: nil)
//    self.navigationController?.pushViewController(vc, animated: false)
//    navigationController?.dismiss(animated: true)
    UserDefaults.standard.set(false, forKey: LoginStatus)
    let storyboard = UIStoryboard(name: "SignUpSignIn", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
    self.navigationController?.pushViewController(controller, animated: false)
    
  }
    func presentDetail(_ viewControllerToPresent: UIViewController) {
           let transition = CATransition()
           transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
           self.view.window!.layer.add(transition, forKey: kCATransition)

           present(viewControllerToPresent, animated: false)
       }
}

//MARK: ContactsPreviewController Delegate
extension HomeVC: ContactsPreviewControllerDelegate {
  func contactsPreviewController(didSelect user: ObjectUser) {
    guard let currentID = userManager.currentUserID() else { return }
    let vc: MessageVC = UIStoryboard.initial(storyboard: .Messages)
    if let conversation = ConversationsMesaage.filter({$0.userIDs.contains(user.id)}).first {
      vc.conversation = conversation
        self.navigationController?.pushViewController(vc, animated: false)
      //show(vc, sender: self)
      return
    }
    let conversation = ObjectConversation()
    conversation.userIDs.append(contentsOf: [currentID, user.id])
    conversation.isRead = [currentID: true, user.id: true]
    vc.conversation = conversation
    show(vc, sender: self)
  }
}

//MARK:- Call Method Delegate
extension HomeVC : CXProviderDelegate
{
   func providerDidReset(_ provider: CXProvider)
   {
    
   }
   func provider(_ provider: CXProvider, perform action: CXAnswerCallAction)
   {
     action.fulfill()
   }
   func provider(_ provider: CXProvider, perform action: CXEndCallAction)
   {
     action.fulfill()
   }
}
/*struct  UserData {
    var UserName: String?
    var Phone: String?
    var ProfilePic : String?
    var Email: String?
    var Password:String?
    var UserID : String?
 init(data: NSDictionary) {
    UserName = data["UserName"] as? String
    Phone = data["Phone"] as? String
    ProfilePic = data["ProfilePic"]as? String
    Email = data["Email"] as? UIImage
    Password = data["Password"] as? UIImage
    UserID = data["UserID"] as? String
    }
 }*/

extension HomeVC
{
  func IsActiveDataGetDark()
  {
    self.arrIsActiveData.removeAll()
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
            self.tblHome.reloadData()
        }
        
    })
  }
}
