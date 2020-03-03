
import UIKit
import Firebase
import FirebaseFirestore
import iOSPhotoEditor

class CameraBaseVC: UIViewController {

    @IBOutlet var ImgFInal: UIImageView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnRight: UIButton!
    @IBOutlet var ColleImage: UICollectionView!
    @IBOutlet var CollectionViewViwe: UIView!
    @IBOutlet var BotomView: UIView!
    
    
    var Index: Int = 0
    var ArrImageSelectedFinal = [UIImage]()
    var arrImageUrl = [String]()
    private let DataManager = UserManager()
    var ref:DatabaseReference?

    var CurrentTime = String()
    var DateCurrent = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        ref = Database.database().reference()

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))

        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        self.BotomView.layer.borderWidth = 1.5
        self.BotomView.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
         super.viewWillAppear(animated)
        let date = Date()
        let dateFormatter = DateFormatter()
        let dateFormatter112 = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("E,h:mm:a")
        dateFormatter112.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter112.dateFormat = "yyyy-MM-dd HH:mm:ss a z"
        let hour = dateFormatter.string(from: date)
        let datec = dateFormatter112.string(from: date)
        self.CurrentTime = hour
        self.DateCurrent = datec
    }
    
    override var shouldAutorotate: Bool
    {
        return false
    }
    
    @IBAction func btncancel(_ sender: Any)
    {
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.image = ArrImageSelectedFinal[Index]
        self.ArrImageSelectedFinal.remove(at: Index)
        self.ColleImage.reloadData()
        //Colors for drawing and Text, If not set default values will be used
        // photoEditor.colors = [.red, .blue, .green]
        
        //Stickers that the user will choose from to add on the image
        for i in 0...42 {
            photoEditor.stickers.append(UIImage(named: i.description )!)
        }
        
        //To hide controls - array of enum control
        photoEditor.hiddenControls = [.share, .clear, .save]
        photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency
        present(photoEditor, animated: true, completion: nil)
        
       
    }
    
    @IBAction func btnRight(_ sender: Any)
    {
        appDelegate.ShowHUD()
        
        let userID = Auth.auth().currentUser!.uid

        UploadImages.uploadImagesss(userId: userID,imagesArray : self.ArrImageSelectedFinal){ (uploadedImageUrlsArray) in
            print("uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
            self.arrImageUrl = uploadedImageUrlsArray
            
            ProfileManager.shared.userData(id: userID) {[weak self] profile in
                       let UserName1 = "\(profile?.username ?? "")"
                       let ProfileUrl1 = "\(profile?.profilePicLink ?? "")"
                       
                       let ref = Database.database().reference()
                       
                       guard let key = ref.child("StatusPost").child(userID).key else { return }
                       
                       let param = ["UserId": userID,
                                    "UserName": UserName1,
                                    "Time": self!.CurrentTime,
                                    "CreateDate":self!.DateCurrent,
                                    "ProfilePic":ProfileUrl1, "Image": self?.arrImageUrl as Any] as [String : Any]
                       
                       let childUpdates = ["/StatusPost/\(key)": param ]
                       ref.updateChildValues(childUpdates)
                       
                       appDelegate.HideHUD()
                       self?.navigationController?.popViewController(animated: false)
                   }
        }
    }
    
    @IBAction func btnback(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CameraBaseVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.ArrImageSelectedFinal.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = ColleImage.dequeueReusableCell(withReuseIdentifier: "CropImageCell", for: indexPath) as! CropImageCell
        
        if indexPath.row == Index
        {
            self.ImgFInal.image = ArrImageSelectedFinal[indexPath.row]
        }
        
        cell.Image.layer.cornerRadius = 3
        cell.Image.clipsToBounds = true
        
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(ImageSelect), for: .touchUpInside)
        
        cell.Image.image = ArrImageSelectedFinal[indexPath.row]
        
        return cell
    }
    
    @objc func ImageSelect(_ sender: UIButton)
    {
        print("ImageSelectPressed !")
        self.Index = sender.tag // = IndexPath(row:  sender.tag, section: 0)
        let Image = ArrImageSelectedFinal[sender.tag]
        self.ImgFInal.image = Image
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
}

extension CameraBaseVC
{
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
    {
        if (sender.direction == .left)
        {
            print("Swipe Left")
            if Index == ArrImageSelectedFinal.count - 1
            {
                Index = 0
            }
            else
            {
                Index += 1
            }
            ImgFInal.image = ArrImageSelectedFinal[Index]
        }
        
        if (sender.direction == .right)
        {
            print("Swipe Right")
            if Index == 0 {
                Index = ArrImageSelectedFinal.count - 1
            }else{
                Index -= 1
            }
            ImgFInal.image = ArrImageSelectedFinal[Index]
        }
    }
}

extension CameraBaseVC: PhotoEditorDelegate{
    
    func doneEditing(image: UIImage) {
        self.ArrImageSelectedFinal.append(image)
        self.ColleImage.reloadData()
        //imageView.image = image
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

