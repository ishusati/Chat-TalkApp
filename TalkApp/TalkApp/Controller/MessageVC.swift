

import UIKit
import Firebase

class MessageVC: UIViewController,KeyboardHandler{

    //MARK:- OUTLET
    @IBOutlet var lblTital: UILabel!
    @IBOutlet weak var tblMessage: UITableView!
    @IBOutlet weak var txtinputText: UITextField!
    @IBOutlet weak var btnExpandButton: UIButton!
    @IBOutlet weak var barBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var btnactionButtons: [UIButton]!
    
    //MARK: Private properties
     private let manager = MessageManager()
     private let imageService = ImagePickerService()
     private let locationService = LocationService()
     private var messages = [ObjectMessage]()
     var IsActive = String()
    
    //MARK: Public properties
    var conversation = ObjectConversation()
    var bottomInset: CGFloat {
      return view.safeAreaInsets.bottom + 50
    }

    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           
        if (Reachability.isConnectedToNetwork() == true)
        {
            addKeyboardObservers() {[weak self] state in
                        guard state else { return }
                        self?.tblMessage.scroll(to: .bottom, animated: true)
                        }
                        fetchMessages()
                        fetchUserName()
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
    
    @IBAction func btnSendMessage(_ sender: Any) {
        
       guard let text = txtinputText.text, !text.isEmpty else { return }
       let message = ObjectMessage()
       message.message = text
       message.ownerID = UserManager().currentUserID()
        self.txtinputText.text = nil
       showActionButtons(false)
       send(message)
     }
     
     @IBAction func btnSendImage(_ sender: UIButton)
     {
        
       imageService.pickImage(from: self, allowEditing: false, source: sender.tag == 0 ? .photoLibrary : .camera) {[weak self] image in
         let message = ObjectMessage()
         message.contentType = .photo
         message.profilePic = image
         message.ownerID = UserManager().currentUserID()
         self?.send(message)
         self?.txtinputText.text = nil
         self?.showActionButtons(false)
       }
     }
     
     @IBAction func btnSendLocation(_ sender: UIButton) {
       locationService.getLocation {[weak self] response in
         switch response {
         case .denied:
           self?.showAlert(title: "Error", message: "Please enable locattion services")
         case .location(let location):
           let message = ObjectMessage()
           message.ownerID = UserManager().currentUserID()
           message.content = location.string
           message.contentType = .location
           self?.send(message)
           self?.txtinputText.text = nil
           self?.showActionButtons(false)
         }
       }
     }
     
    @IBAction func btnOpenCamera(_ sender: UIButton)
    {
        imageService.pickImage(from: self, allowEditing: false, source: .camera) {[weak self] image in
       let message = ObjectMessage()
        message.contentType = .photo
       message.profilePic = image
       message.ownerID = UserManager().currentUserID()
       self?.send(message)
       self?.txtinputText.text = nil
       self?.showActionButtons(false)
     }
            
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
       // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnExpandItems(_ sender: UIButton) {
       showActionButtons(true)
     }
}


//MARK: Private methods
extension MessageVC {
  
  private func fetchMessages() {
    manager.messages(for: conversation) {[weak self] messages in
      self?.messages = messages.sorted(by: {$0.timestamp < $1.timestamp})
      self?.tblMessage.reloadData()
      self?.tblMessage.scroll(to: .bottom, animated: true)
    }
  }
  
  private func send(_ message: ObjectMessage) {
    manager.create(message, conversation: conversation) {[weak self] response in
      guard let weakSelf = self else { return }
      if response == .failure {
        weakSelf.showAlert()
        return
      }
      weakSelf.conversation.timestamp = Int(Date().timeIntervalSince1970)
      switch message.contentType {
      case .none: weakSelf.conversation.lastMessage = message.message
      case .photo: weakSelf.conversation.lastMessage = "Attachment"
      case .location: weakSelf.conversation.lastMessage = "Location"
      default: break
      }
      if let currentUserID = UserManager().currentUserID() {
        weakSelf.conversation.isRead[currentUserID] = true
      }
      ConversationManager().create(weakSelf.conversation)
    }
  }
  
  private func fetchUserName() {
    guard let currentUserID = UserManager().currentUserID() else { return }
    guard let userID = conversation.userIDs.filter({$0 != currentUserID}).first else { return }
    UserManager().userData(for: userID) {[weak self] user in
      guard let name = user?.username else { return }
        self?.lblTital.text = "\(name),  \(self!.IsActive)"
      self?.navigationItem.title = name
    }
  }
  
  private func showActionButtons(_ status: Bool) {
    guard !status else {
      stackViewWidthConstraint.constant = 112
      UIView.animate(withDuration: 0.3) {
        self.btnExpandButton.isHidden = true
        self.btnExpandButton.alpha = 0
        self.btnactionButtons.forEach({$0.isHidden = false})
        self.view.layoutIfNeeded()
      }
      return
    }
    guard stackViewWidthConstraint.constant != 32 else { return }
    stackViewWidthConstraint.constant = 32
    UIView.animate(withDuration: 0.3) {
      self.btnExpandButton.isHidden = false
      self.btnExpandButton.alpha = 1
      self.btnactionButtons.forEach({$0.isHidden = true})
      self.view.layoutIfNeeded()
    }
  }
}

//MARK: UITableView Delegate & DataSource
extension MessageVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = messages[indexPath.row]
       if message.contentType == .none {
         let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == UserManager().currentUserID() ? "MessageTableViewCell" : "UserMessageTableViewCell") as! MessageTableViewCell
         cell.set(message)
         return cell
       }
       let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == UserManager().currentUserID() ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
       cell.delegate = self
       cell.set(message)
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard tableView.isDragging else { return }
    cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    UIView.animate(withDuration: 0.3, animations: {
      cell.transform = CGAffineTransform.identity
    })
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    switch message.contentType {
    case .location:
        let vc: MapVC = UIStoryboard.controller(storyboard: .Previews)
       vc.locationString = message.content
       navigationController?.present(vc, animated: true)
    case .photo:
        let vc: ImageVC = UIStoryboard.controller(storyboard: .Previews)
      vc.imageURLString = message.profilePicLink
      navigationController?.present(vc, animated: true)
    default: break
    }
  }
}


//MARK: UItextField Delegate
extension MessageVC: UITextFieldDelegate {
    
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    showActionButtons(false)
    return true
  }
}

//MARK: MessageTableViewCellDelegate Delegate
extension MessageVC: MessageTableViewCellDelegate {
  
  func messageTableViewCellUpdate() {
    tblMessage.beginUpdates()
    tblMessage.endUpdates()
  }
}
