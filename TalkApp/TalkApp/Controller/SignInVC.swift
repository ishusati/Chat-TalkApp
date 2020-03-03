

import UIKit
import FirebaseDatabase
import Firebase

class SignInVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet var BaseViewCenterYContraint: NSLayoutConstraint!
    @IBOutlet var BaseView: UIView!
    @IBOutlet var EmailView: UIView!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var PasswordView: UIView!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet weak var cloudsImageView: UIImageView!
    @IBOutlet var CloudImageLeadingContraint: NSLayoutConstraint!
    
    //MARK:- VARIABLE
    private let DataManager = UserManager()
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.SetUpVC()
    }
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.BaseViewCenterYContraint.constant = -30
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
          self.view.layoutIfNeeded()
        })
        
        if (Reachability.isConnectedToNetwork() == true)
        {
           
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
    
    //MARK:-VIEWDIDAPPEAR
    override func viewDidAppear(_ animated: Bool)
    {
      super.viewDidAppear(animated)
      animateClouds()
    }
    
    //MARK:- STATUSBAR
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }
    
    //MARK:- ACTION
    @IBAction func btnSignIn(_ sender: Any)
    {
        if (Reachability.isConnectedToNetwork() == true)
        {
           self.SignInCheckData()
        }
        else
        {
            let net = appDelegate.InternetConnectionErrorApp(view: self.view)
            net.isUserInteractionEnabled = true
            net.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeNetView)))
        }
    }
    
    @IBAction func btnSignUp(_ sender: Any)
    {
      if (Reachability.isConnectedToNetwork() == true)
        {
            self.performSegue(withIdentifier: "SignUp", sender: self)
        }
        else
        {
            let net = appDelegate.InternetConnectionErrorApp(view: self.view)
            net.isUserInteractionEnabled = true
            net.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeNetView)))
        }
    }
}

extension SignInVC
{
  fileprivate func SetUpVC()
  {
    self.txtEmail.attributedPlaceholder = NSAttributedString(string: "Enter Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    self.txtPassword.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    
    self.txtEmail.keyboardType = .emailAddress
    
    self.txtEmail.delegate = self
    self.txtPassword.delegate = self
    
    self.BaseView.layer.cornerRadius = 10
    self.EmailView.layer.cornerRadius = 18
    self.PasswordView.layer.cornerRadius = 18
    self.btnSignIn.layer.cornerRadius = 18
    self.btnSignUp.layer.cornerRadius = 18
  }
    
  fileprivate func SignInCheckData()
  {
    guard let Email = txtEmail.text, let Pass = txtPassword.text else { return }

    if Email.isEmpty{
         appDelegate.showToast(title: "Error", message: "Enter Email Address", ImageName: "close")
    }
    else if !Email.isValidEmail(){
       appDelegate.showToast(title: "Error", message: "Enter Valid Email Address", ImageName: "close")
    }
    else if Pass.isEmpty{
        appDelegate.showToast(title: "Error", message: "Enter Password", ImageName: "error")
    }
    else if Pass.count < 8{
         appDelegate.showToast(title: "Error", message: "Password Minimam Lenth Should be 8 charaters", ImageName: "error")
    }
    else {

        let UserData = ObjectUser()
        UserData.email = Email
        UserData.password = Pass
        
        appDelegate.ShowHUD()
        DataManager.login(user: UserData) {[weak self] response in
        appDelegate.HideHUD()
            
            switch response{
            case.success: appDelegate.showToast(title: "Successfull Login", message: "", ImageName: "sucessAlert")
            
             let userID = Auth.auth().currentUser!.uid
             let ref = Database.database().reference()
            
            guard let key = ref.child("IsOnline").child(userID).key else { return }
            let param = ["UserId":userID, "IsActive":"Yes"]
            let childUpdates = ["/IsOnline/\(key)": param ]
            ref.updateChildValues(childUpdates)
            
                UserDefaults.standard.set(true, forKey: LoginStatus)
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "HomeToHomeVC") as! HomeToHomeVC
                self?.navigationController?.pushViewController(controller, animated: true)
                
                
            case .failure: appDelegate.showToast(title: "Error", message: "Something went wrong", ImageName: "close")
            }
        }
    }
  }
}

//MARK: Private methods
extension SignInVC {
  
  private func animateClouds() {
    CloudImageLeadingContraint.constant = 0
    cloudsImageView.layer.removeAllAnimations()
    view.layoutIfNeeded()
    let distance = view.bounds.width - cloudsImageView.bounds.width
    self.CloudImageLeadingContraint.constant = distance
    UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
      self.view.layoutIfNeeded()
    })
  }
}

// MARK: - UITextFieldDelegate
extension SignInVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == self.txtEmail)
        {
            if txtPassword.text!.count > 0
            {
                txtEmail.resignFirstResponder()
                txtEmail.returnKeyType = .done
            }
            else
            {
                txtEmail.returnKeyType = .next
                txtPassword.becomeFirstResponder()
            }
        }
        else if (textField == self.txtPassword)
        {
            txtPassword.resignFirstResponder()
            txtPassword.returnKeyType = .done
        }
         return true
    }
 }


