

import UIKit
import Parchment
import Firebase

class HomeToHomeVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet var MainView: UIView!
    @IBOutlet var ProfileImage: UIImageView!
    
    @IBOutlet var UserImage: UIImageView!
    //MARK:- Variable
    let pagingViewController = PagingViewController()

    private var ConversationsMesaage = [ObjectConversation]()
    private var UserData: ObjectUser?
    private let DataManager = ConversationManager()
    private let userManager = UserManager()
    
    let Inbox = ["Home","Status","Camera"]
    
    //MARK:- ViewdidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        pagingViewController.font = UIFont.init(name: "EtelkaMediumPro-Bold", size: 15.0)!
        pagingViewController.selectedFont = UIFont.init(name: "EtelkaMediumPro-Bold", size: 18.0)!
        
        let width = view.bounds.width/3
        pagingViewController.menuItemSize = .fixed(width: width, height: 50)
        
        pagingViewController.backgroundColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
        pagingViewController.selectedBackgroundColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
        
        pagingViewController.indicatorColor = UIColor.white
        pagingViewController.textColor = #colorLiteral(red: 0.6235294118, green: 0.5732975134, blue: 1, alpha: 1)
        pagingViewController.selectedTextColor =  UIColor.white
        pagingViewController.becomeFirstResponder()
        
        self.addChild(pagingViewController)
        self.MainView.addSubview(pagingViewController.view)
        self.MainView.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
         super.viewWillAppear(animated)
         pagingViewController.reloadData()
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
              rotationAnimation.toValue = .pi * 2.0 * 2 * 60.0
              rotationAnimation.duration = 300.0
              rotationAnimation.isCumulative = false
              rotationAnimation.repeatCount = Float.infinity
              ProfileImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    //MARK:- Action
    @IBAction func btnAllFriend(_ sender: Any)
    {
        let vc: ContactsVC = UIStoryboard.controller(storyboard: .Previews)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
        present(vc, animated: true, completion: nil)
    }
    @IBAction func btnProfile(_ sender: Any)
    {
        let vc: ProfileVC = UIStoryboard.initial(storyboard: .Profile)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}

//MARK:- Method Delegate
extension HomeToHomeVC: PagingViewControllerDataSource,PagingViewControllerDelegate {
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: Inbox[index])
    }
    
     func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        switch index {
        case 0:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller : HomeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            return controller
        case 1:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller : StatusVC = storyboard.instantiateViewController(withIdentifier: "StatusVC") as! StatusVC
            return controller
            
        case 2:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller : CameraVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
            return controller
            
        default:
            break
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller : HomeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        return controller
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
         return Inbox.count
    }
}

//MARK: ContactsPreviewController Delegate
extension HomeToHomeVC: ContactsPreviewControllerDelegate {
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

//MARK: ProfileViewController Delegate
extension HomeToHomeVC: ProfileViewControllerDelegate {
  func profileViewControllerDidLogOut() {
    userManager.logout()
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



