

import UIKit
import Firebase
import Kingfisher
import Foundation

class StatusVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet var tblStatus: UITableView!
    @IBOutlet var UserView: UIView!
    @IBOutlet var UserProfile: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblMobileNu: UILabel!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var UserVIewYContraint: NSLayoutConstraint!
    
    var ArrStatusData = [Status]()
    var ArrImage: NSArray = NSArray()

    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tblStatus.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tblStatus.tableFooterView = UIView()
         
        self.UserView.layer.cornerRadius = 13
        self.btnDelete.layer.cornerRadius = 15
        self.UserProfile.layer.cornerRadius = self.UserProfile.frame.height/2
        self.UserProfile.clipsToBounds = true
    }
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
           
        if (Reachability.isConnectedToNetwork() == true)
        {
            self.StatusDataGet()
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

    @IBAction func btnDelete(_ sender: Any)
    {
      let userID = Auth.auth().currentUser!.uid
      FirebaseDatabase.Database.database().reference(withPath: "StatusPost").child(userID).setValue(nil)
        
     appDelegate.showToast(title: "Successfull", message: "your status is delete", ImageName: "sucessAlert")
        
     UserVIewYContraint.constant = 1000
     UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
       self.view.layoutIfNeeded()
         self.StatusDataGet()
      })
    }
    
    @IBAction func btnClose(_ sender: Any)
    {
     UserVIewYContraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
         })
    }
}

//MARK:- TABLEVIEW METHOD
extension StatusVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ArrStatusData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       let cell = tableView.dequeueReusableCell(withIdentifier: StatusCell.className) as! StatusCell
        
        cell.BaseView.layer.cornerRadius = 10
        cell.BaseView.layer.borderWidth = 1.5
        cell.BaseView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        cell.ProfilePic.layer.cornerRadius = cell.ProfilePic.frame.height/2
        cell.clipsToBounds = true
        
        cell.selectionStyle = .none
        
        cell.btnDelete.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        
        cell.lblUserName.text = ArrStatusData[indexPath.row].UserName
        cell.lblTime.text = ArrStatusData[indexPath.row].Time

        let Image = ArrStatusData[indexPath.row].ProfilePic
        
        if Image?.isEmpty == true
        {
            cell.ProfilePic.image = UIImage(named: "profile pic")
        }
        else
        {
           cell.ProfilePic.setImage(url: URL(string: Image!))
           cell.ProfilePic.layer.borderWidth = 1.5
           cell.ProfilePic.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
           cell.ProfilePic.clipsToBounds = true
        }
    
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
      //  let cell = tableView.cellForRow(at: indexPath) as! StatusCell
       // let currentCell = tableView.cellForRowAtIndexPath(indexPath.row) as StatusCell
        
        let userid = ArrStatusData[indexPath.row].UserId
        let Time =  ArrStatusData[indexPath.row].Time
        let ref = Database.database().reference().child("StatusPost")
        ref.child(userid!).child("Image").observeSingleEvent(of: .value, with: { (snapshot) in
        let ImageData1 = snapshot.value as! NSArray
        self.ArrImage = ImageData1
            
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "StoryVC") as! StoryVC
        controller.modalPresentationStyle = .fullScreen
        controller.ArrImageData = self.ArrImage
        controller.userID = userid!
        controller.Time = Time!
        self.present(controller, animated: true, completion: nil)
            
      })
    }
    
   @objc func connected(sender: UIButton)
   {
    let Id = ArrStatusData[sender.tag].UserId
    let userID = Auth.auth().currentUser!.uid
    
    if userID == Id
    {
      ProfileManager.shared.userData(id: Id!) {[weak self] profile in
          self?.lblUserName.text = "UserName: \(profile?.username ?? "")"
          self?.lblMobileNu.text = "Phone: \(profile?.mobilenumber ?? "")"
          self?.lblEmail.text = "Email: \(profile?.email ?? "")"
          
          guard let urlString = profile?.profilePicLink else {
              self?.UserProfile.image = UIImage(named: "profile pic")
              return
          }
          self?.UserProfile.setImage(url: URL(string: urlString))
      }
      UserVIewYContraint.constant = 0
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
          self.view.layoutIfNeeded()
      })
    }
    else
    {
        
    }
   }
    
}

extension StatusVC
{
  func StatusDataGet()
  {
    self.ArrStatusData.removeAll()
      
     let ref = Database.database().reference().child("StatusPost")
     ref.observe(.childAdded, with: { snapshot in
        let dict = snapshot.value as! [String: Any]
        let UserName = dict["UserName"] as? String ?? ""
        let UserId = dict["UserId"] as? String ?? ""
        let ProfilePic = dict["ProfilePic"] as? String ?? ""
        let Time = dict["Time"] as? String ?? ""
        let CreateDate = dict["CreateDate"] as? String ?? ""
        print("snapshot.key \(snapshot.key)")
        self.timeGapBetweenDates(CreateDateStatus: CreateDate, UserName: UserName, UserId: UserId, ProfilePic: ProfilePic, Time: Time, SnapKey: snapshot.key)
    })
  }
    
    func timeGapBetweenDates(CreateDateStatus:String,UserName: String,UserId:String,ProfilePic: String,Time: String,SnapKey : String)
    {
        let date1 = CreateDateStatus.stringToDate()
        let distanceBetweenDates: TimeInterval = Date().timeIntervalSince(date1)
        let secondsInAnHour: Double = 3600
        let minsInAnHour: Double = 60
        let secondsInDays: Double = 86400
        let secondsInWeek: Double = 604800
        let secondsInMonths : Double = 2592000
        let secondsInYears : Double = 31104000

        let minBetweenDates = Int(((distanceBetweenDates) / minsInAnHour))
        let hoursBetweenDates = Int((distanceBetweenDates / secondsInAnHour))
        let daysBetweenDates = Int((distanceBetweenDates / secondsInDays))
        let weekBetweenDates = Int((distanceBetweenDates / secondsInWeek))
        let monthsbetweenDates = Int((distanceBetweenDates / secondsInMonths))
        let yearbetweenDates = Int((distanceBetweenDates / secondsInYears))
        let secbetweenDates = Int(distanceBetweenDates)

        if yearbetweenDates > 0
        {
            print(yearbetweenDates,"years")//0 years
            FirebaseDatabase.Database.database().reference(withPath: "StatusPost").child(SnapKey).setValue(nil)
        }
        else if monthsbetweenDates > 0
        {
            print(monthsbetweenDates,"months")//0 months
            FirebaseDatabase.Database.database().reference(withPath: "StatusPost").child(SnapKey).setValue(nil)
        }
        else if weekBetweenDates > 0
        {
            print(weekBetweenDates,"weeks")//0 weeks
            FirebaseDatabase.Database.database().reference(withPath: "StatusPost").child(SnapKey).setValue(nil)
        }
        else if daysBetweenDates > 0
        {
            print(daysBetweenDates,"days")//5 days
            if daysBetweenDates >= 1
            {
             FirebaseDatabase.Database.database().reference(withPath: "StatusPost").child(SnapKey).setValue(nil)
            }
            else
            {
              self.ArrStatusData.insert(Status(UserId: UserId, UserName: UserName, ProfilePic: ProfilePic, Time: Time), at: 0)
              self.tblStatus.reloadData()
            }
        }
        else if hoursBetweenDates > 0
        {
            print(hoursBetweenDates,"hours")//120 hours
            if hoursBetweenDates > 24
            {
               FirebaseDatabase.Database.database().reference(withPath: "StatusPost").child(SnapKey).setValue(nil)
            }
            else
            {
              self.ArrStatusData.insert(Status(UserId: UserId, UserName: UserName, ProfilePic: ProfilePic, Time: Time), at: 0)
              self.tblStatus.reloadData()
            }
        }
        else if minBetweenDates > 0
        {
            print(minBetweenDates,"minutes")//7200 minutes
            self.ArrStatusData.insert(Status(UserId: UserId, UserName: UserName, ProfilePic: ProfilePic, Time: Time), at: 0)
            self.tblStatus.reloadData()
        }
        else if secbetweenDates > 0
        {
            print(secbetweenDates,"seconds")//seconds
            self.ArrStatusData.insert(Status(UserId: UserId, UserName: UserName, ProfilePic: ProfilePic, Time: Time), at: 0)
            self.tblStatus.reloadData()
        }
    }
   
}

struct Status {
var UserId: String!
var UserName : String!
var ProfilePic: String!
var Time : String!
var StatusImage: NSArray = NSArray()
}
struct IsActiveData {
    var isActive: String!
    var UserID: String!
}


extension String
{
  func stringToDate(inputFormate:String = "yyyy-MM-dd hh:mm:ss a z", inputTZ:TimeZone? = TimeZone(abbreviation: "UTC"), outputTZ:TimeZone? = TimeZone(abbreviation: "UTC")) -> Date {
        let dateFormate = DateFormatter()
        dateFormate.timeZone = inputTZ
        dateFormate.dateFormat = inputFormate
        dateFormate.timeZone = outputTZ
        return dateFormate.date(from: self) ?? Date()
    }
}
