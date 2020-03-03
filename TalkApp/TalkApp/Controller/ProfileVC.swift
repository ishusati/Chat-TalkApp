

import UIKit
import Firebase


class ProfileVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet var BaseView: UIView!
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var btnConnect: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var AnimationContraint: NSLayoutConstraint!
    @IBOutlet var btnBackground: UIButton!
    
    //MARK:- VARIABLE
    var delegate: ProfileViewControllerDelegate?
    
    private let picker = UIImagePickerController()
    private let DataManager = UserManager()
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
       super.viewDidLoad()
        
       self.BaseView.layer.cornerRadius = 13
       self.btnCancel.layer.cornerRadius = 15
       self.btnConnect.layer.cornerRadius = 15
        
       self.ProfileImage.layer.cornerRadius = self.ProfileImage.frame.height/2
       self.ProfileImage.clipsToBounds = true
    }
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
         AudioService().playSound()
      AnimationContraint.constant = 0
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
        self.btnBackground.alpha = 0.8
        self.view.layoutIfNeeded()
      })
        
      if (Reachability.isConnectedToNetwork() == true)
      {
        let userID = Auth.auth().currentUser!.uid

        ProfileManager.shared.userData(id: userID) {[weak self] profile in
               self?.lblUserName.text = "UserName: \(profile?.username ?? "")"
               self?.lblPhone.text = "Phone: \(profile?.mobilenumber ?? "")"
               self?.lblEmail.text = "Email: \(profile?.email ?? "")"
               
             guard let urlString = profile?.profilePicLink else {
               self?.ProfileImage.image = UIImage(named: "profile pic")
               return
             }
             self?.ProfileImage.setImage(url: URL(string: urlString))
            self!.ProfileImage.layer.borderWidth = 2.5
             self!.ProfileImage.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
             self!.ProfileImage.clipsToBounds = true
           }
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
      modalPresentationStyle = .overFullScreen
    }
    
    //MARK:- ACTION
    
    @IBAction func btnProfileUpdate(_ sender: Any)
    {
//        let Alert = UIAlertController(title: "", message: "Change Display Picture ", preferredStyle: .actionSheet)
//
//        let ok = UIAlertAction(title: "Choose Picture", style: .default) { (UIAlertAction) in
//
//          self.openGallary()
//        }
//
//        Alert.addAction(ok)
//
//        let photo = UIAlertAction(title: "Take Photo", style: .default) { (UIAlertAction) in
//
//          self.Camera()
//        }
//
//        Alert.addAction(photo)
//
//        let photo1 = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
//
//        }
//
//        Alert.addAction(photo1)
//
//        self.present(Alert, animated: true, completion: nil)
    }
    @IBAction func btnCancel(_ sender: Any)
    {
        AnimationContraint.constant = view.bounds.height
           UIView.animate(withDuration: 0.3, animations: {
             self.btnBackground.alpha = 0
             self.view.layoutIfNeeded()
           }) { _ in
            
            let userID = Auth.auth().currentUser!.uid
            let ref = Database.database().reference()
            
            guard let key = ref.child("IsOnline").child(userID).key else { return }
            let param = ["UserId":userID, "IsActive":"no"]
            let childUpdates = ["/IsOnline/\(key)": param ]
            ref.updateChildValues(childUpdates)
            
             self.dismiss(animated: false, completion: nil)
            self.delegate?.profileViewControllerDidLogOut()
           }
    }
    @IBAction func btnIsConnect(_ sender: Any)
    {
      AnimationContraint.constant = view.bounds.height
         UIView.animate(withDuration: 0.3, animations: {
           self.btnBackground.alpha = 0
           self.view.layoutIfNeeded()
         }) { _ in
           self.dismiss(animated: false, completion: nil)
         }
    }
}

protocol ProfileViewControllerDelegate: class {
  func profileViewControllerDidLogOut()
}


//MARK: UIImagePickerController Delegate
extension ProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let img = info[.editedImage] as? UIImage
        {
            let value = img
            self.ProfileImage.image = value
            self.ProfileImage.contentMode = .scaleToFill
            
            let UserData = ObjectUser()
            UserData.profilePic = ProfileImage.image
             
            if (Reachability.isConnectedToNetwork() == true)
            {
                  dismiss(animated: true, completion: nil)
                  appDelegate.ShowHUD()
                  DataManager.update(user: UserData) {[weak self] response in
                  appDelegate.HideHUD()
                          
                
                  switch response{
                  case .success: appDelegate.showToast(title: "Successful ProfilePic Change", message: "", ImageName: "sucessAlert")
                  self?.navigationController?.popViewController(animated: true)
                  case .failure: appDelegate.showToast(title: "Error", message: "Something went wrong", ImageName: "sucessAlert")
                    }
                }
            }
            else
            {
                let net = appDelegate.InternetConnectionErrorApp(view: self.view)
                net.isUserInteractionEnabled = true
                net.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeNetView)))
                  dismiss(animated: true, completion: nil)
            }
            
       
        }
        else if let img = info[.originalImage] as? UIImage
        {
            let value = img
            self.ProfileImage.image = value
            self.ProfileImage.contentMode = .scaleToFill
            
            let UserData = ObjectUser()
            UserData.profilePic = ProfileImage.image
                       
            if (Reachability.isConnectedToNetwork() == true)
            {
                  dismiss(animated: true, completion: nil)
                  appDelegate.ShowHUD()
                  DataManager.update(user: UserData) {[weak self] response in
                  appDelegate.HideHUD()
                              
                  switch response{
                  case .success: appDelegate.showToast(title: "Successful ProfilePic Change", message: "", ImageName: "sucessAlert")
                  self?.navigationController?.popViewController(animated: true)
                  case .failure: appDelegate.showToast(title: "Error", message: "Something went wrong", ImageName: "sucessAlert")
                    }
                }
            }
            else
            {
                let net = appDelegate.InternetConnectionErrorApp(view: self.view)
                net.isUserInteractionEnabled = true
                net.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeNetView)))
                  dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true,completion: nil)
    }
}

extension ProfileVC
{
    func Camera()
    {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil
        {
            self.picker.delegate = self
            self.picker.allowsEditing = true
            self.picker.sourceType = .camera
            self.picker.cameraDevice = .rear
            self.picker.sourceType = UIImagePickerController.SourceType.camera
            self.picker.cameraCaptureMode = .photo
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            self.Nodevicecamera()
        }
     }
          
       func Nodevicecamera()
       {
           let Alert = UIAlertController(title: "No Camera", message: "Your Device Not Support in Camera", preferredStyle: .alert)
                 
           let ok = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                     
           }
                 
           Alert.addAction(ok)
           self.present(Alert, animated: true, completion: nil)
       }
          
       func openGallary()
       {
           self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
           self.picker.delegate = self
           self.picker.allowsEditing = true
           self.present(picker, animated: true, completion: nil)
       }
}
