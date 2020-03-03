

import UIKit
import Firebase
import FirebaseDatabase

class SignUpVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet var BaseView: UIView!
    @IBOutlet var ImgProfile: UIImageView!
    @IBOutlet var EmailView: UIView!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var UserNameView: UIView!
    @IBOutlet var txtUserName: UITextField!
    @IBOutlet var PasswordView: UIView!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var PhoneNuView: UIView!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var btnSignUp: UIButton!
    
    //MARK:- VARIABLE
    private let picker = UIImagePickerController()
    private let DataManager = UserManager()
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.SetUpVC()
    }
    
    //MARK:- STATUSBAR
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
           
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
    
    //MARK:- ACTION
    @IBAction func btnBack(_ sender: Any)
    {
      self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelectProfileImage(_ sender: Any)
    {
        let Alert = UIAlertController(title: "", message: "Change Display Picture ", preferredStyle: .actionSheet)
                                                    
        let ok = UIAlertAction(title: "Choose Picture", style: .default) { (UIAlertAction) in
                                
          self.openGallary()
        }
                            
        Alert.addAction(ok)
                
       let photo = UIAlertAction(title: "Take Photo", style: .default) { (UIAlertAction) in
        
          self.Camera()
        }
                            
         Alert.addAction(photo)
                        
        let photo1 = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
                            
        Alert.addAction(photo1)
                            
        self.present(Alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSignUp(_ sender: Any)
    {
        if (Reachability.isConnectedToNetwork() == true)
        {
          self.SignUpCheckData()
        }
        else
        {
            let net = appDelegate.InternetConnectionErrorApp(view: self.view)
            net.isUserInteractionEnabled = true
            net.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeNetView)))
        }
    }
}

extension SignUpVC
{
   fileprivate func SetUpVC()
   {
     self.txtEmail.attributedPlaceholder = NSAttributedString(string: "Enter Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
     self.txtPassword.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    self.txtUserName.attributedPlaceholder = NSAttributedString(string: "Enter Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    self.txtPhone.attributedPlaceholder = NSAttributedString(string: "Enter MobileNumber", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    
    self.txtEmail.keyboardType = .emailAddress
    self.txtPhone.keyboardType = .phonePad
    
    self.txtEmail.delegate = self
    self.txtPassword.delegate = self
    self.txtUserName.delegate = self
    self.txtPhone.delegate = self
    
    self.ImgProfile.layer.cornerRadius = ImgProfile.frame.height/2
    self.ImgProfile.clipsToBounds = true
    
    self.BaseView.layer.cornerRadius = 10
    self.EmailView.layer.cornerRadius = 18
    self.UserNameView.layer.cornerRadius = 18
    self.PasswordView.layer.cornerRadius = 18
    self.PhoneNuView.layer.cornerRadius = 18
    self.btnSignUp.layer.cornerRadius = 18
   }
    
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
    
    fileprivate func SignUpCheckData()
    {
        guard let Email = self.txtEmail.text, let UserName = txtUserName.text, let Pass = txtPassword.text, let MobileNu = txtPhone.text  else { return }
        
        if Email.isEmpty{
            appDelegate.showToast(title: "Error", message: "Enter Email Address", ImageName: "close")
        }
        else if !Email.isValidEmail(){
            appDelegate.showToast(title: "Error", message: "Enter Valid Email Address", ImageName: "close")
        }
        else if UserName.isEmpty{
           appDelegate.showToast(title: "Error", message: "Enter Username", ImageName: "close")
        }
        else if Pass.isEmpty{
            appDelegate.showToast(title: "Error", message: "Enter Password", ImageName: "close")
        }
        else if !Pass.isValidPassword(){
             appDelegate.showToast(title: "Error", message: "Please Ensure that you have at least one lower case letter, one upper case letter, one digit and one special character", ImageName: "close")
        }
        else if MobileNu.isEmpty{
             appDelegate.showToast(title: "Error", message: "Enter Mobile Number", ImageName: "close")
        }
        else if MobileNu.count < 14 {
            appDelegate.showToast(title: "Error", message: "Enter Valid Mobile Number", ImageName: "close")
        }
        else{
            
            let UserData = ObjectUser()
            UserData.email = Email
            UserData.username = UserName
            UserData.password = Pass
            UserData.mobilenumber = MobileNu
            UserData.profilePic = ImgProfile.image
            
            appDelegate.ShowHUD()
            DataManager.register(user: UserData) {[weak self] response in
            appDelegate.HideHUD()
                
                switch response{
                case .success: appDelegate.showToast(title: "Successful SignUp", message: "", ImageName: "sucessAlert")
                self?.navigationController?.popViewController(animated: true)
                    
                    
                case .failure: appDelegate.showToast(title: "Error", message: "Something went wrong \(Error.self)", ImageName: "sucessAlert")
                }
            }
        }
    }
}

//MARK: UIImagePickerController Delegate
extension SignUpVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let img = info[.editedImage] as? UIImage
        {
            let value = img
            self.ImgProfile.image = value
            self.ImgProfile.contentMode = .scaleToFill
            dismiss(animated: true, completion: nil)
        }
        else if let img = info[.originalImage] as? UIImage
        {
            let value = img
            self.ImgProfile.image = value
            self.ImgProfile.contentMode = .scaleToFill
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true,completion: nil)
    }
}

//MARK: UITextField Delegate
extension SignUpVC: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtPhone
        {
            var fullString = textField.text ?? ""
               fullString.append(string)
               if range.length == 1 {
                   textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
               } else {
                   textField.text = format(phoneNumber: fullString)
               }
               return false
        }
//        else if textField == txtPassword
//        {
//            let maxLength = 8
//            let currentString: NSString = textField.text as! NSString
//            let newString: NSString =
//                currentString.replacingCharacters(in: range, with: string) as NSString
//            return newString.length <= maxLength
//        }
        else
        {
          return true
        }
    }

    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String
    {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }

        return number
    }
}
