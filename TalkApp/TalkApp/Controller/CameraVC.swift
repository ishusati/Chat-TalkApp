
import UIKit
import Photos


class CameraVC: UIViewController,AVCaptureMetadataOutputObjectsDelegate{

  
    //MARK:- FooterView
    @IBOutlet var RoundView: UIView!
    @IBOutlet var btnInside: UIButton!
    @IBOutlet var btnFlashLight: UIButton!
    @IBOutlet var btnFruntBack: UIButton!
    @IBOutlet var ImageView: UIView!
    @IBOutlet var CatchImage: UIImageView!
    @IBOutlet var btnCount: UIButton!
    @IBOutlet var CameraChangeMode: UIImageView!
    @IBOutlet var ImfFlshLIght: UIImageView!
    
    @IBOutlet var GalleryMain: UIView!
    @IBOutlet var GalleryTop: UIView!
    @IBOutlet var GalleryHeight: NSLayoutConstraint!
    @IBOutlet var CollectioView: UICollectionView!
    //MARK:- GalleryView
    @IBOutlet var AddImageView: UIView!
    @IBOutlet var SelectImageOkk: UIImageView!
    
    //MARK:- Variable
    var arrAllGalleryImage = PHFetchResult<PHAsset>()
    var assetMediaType:PHAssetMediaType = .image
    var picker = UIImagePickerController()
    
    let lightBlue = UIColor(red: 24/255, green: 125/255, blue: 251/255, alpha: 1)
    let redColor = UIColor(red: 229/255, green: 77/255, blue: 67/255, alpha: 1)
    
    var ArrImageSelected = [UIImage]()
    var ArrImageIndex = [Int]()
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var flash: AVCaptureDevice.FlashMode = .off
    var isFlash : Bool = false
    var GetImage = UIImage()
    var photosCountLimit = 50
    
    var runningAnimations = [UIViewPropertyAnimator]()
    
    enum CardState {
           case expanded
           case collapsed
       }
    
    var cardVisible = false
       var nextState:CardState {
           return cardVisible ? .collapsed : .expanded
       }
    
    let cardHeight:CGFloat = 500
    let cardHandleAreaHeight:CGFloat = 75
    
    //MARK:- ViewdDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getAllGalleryPhotos()
        self.AddImageView.isHidden = true
    
        let singleTap = UITapGestureRecognizer(target: self, action: Selector(("tapDetected")))
        singleTap.numberOfTapsRequired = 1

        SelectImageOkk.isUserInteractionEnabled = true
        SelectImageOkk.addGestureRecognizer(singleTap)
        
        self.ImageView.isHidden = true
        
        self.RoundView.layer.cornerRadius = self.RoundView.frame.height/2
        self.RoundView.clipsToBounds = true
        self.RoundView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        self.btnInside.layer.cornerRadius = self.btnInside.frame.height/2
        self.btnInside.clipsToBounds = true
        self.btnInside.backgroundColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
        
        self.ImfFlshLIght.image = UIImage(named: "flash-off1")
        self.ImfFlshLIght.image = ImfFlshLIght.image?.withRenderingMode(.alwaysTemplate)
        ImfFlshLIght.tintColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
        
        self.CameraChangeMode.image = UIImage(named: "switch-camera1")
        self.CameraChangeMode.image = CameraChangeMode.image?.withRenderingMode(.alwaysTemplate)
        CameraChangeMode.tintColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
        
        self.CatchImage.layer.cornerRadius = 5
        self.CatchImage.clipsToBounds = true
        
        self.btnCount.layer.cornerRadius = 5
        self.btnCount.clipsToBounds = true

        self.GalleryTop.layer.cornerRadius = 5
        self.GalleryTop.clipsToBounds = true

      
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan(recognizer:)))
        
        self.GalleryMain.addGestureRecognizer(tapGestureRecognizer)
        self.GalleryMain.addGestureRecognizer(panGestureRecognizer)
        
        if let layout = CollectioView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal  // .horizontal
        }
//        setupCaptureSession()
//        setupDevice()
//        setupInputOutput()
//        setupPreviewLayer()
//        startRunningCaptureSession()
//        
        self.ArrImageSelected.removeAll()
        self.ArrImageIndex.removeAll()
        self.hideOrShowPreview()
    }
    
    @objc func wasDragged(_ gestureRecognizer: UIPanGestureRecognizer) {

        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {

            let translation = gestureRecognizer.translation(in: self.view)
            print(gestureRecognizer.view!.center.y)

            if(gestureRecognizer.view!.center.y < 555) {

                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)

            }else {
                gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:554)
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }
    //MARK:-ViewWillAppear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
      
        navigationController?.navigationBar.isHidden = true
       
        AudioService().playSound()
    }
    
    //MARK:- Action
    @IBAction func btnMain(_ sender: UIButton)
    {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    @IBAction func CameraModeChange(_ sender: Any)
    {
      self.swapCamera()
    }
    @IBAction func FlashLightOnOf(_ sender: Any)
    {
       self.toggleFlash()
    }
    @IBAction func btnCount(_ sender: Any) {
    }
}

extension CameraVC
{
    func setupCaptureSession()
    {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice()
    {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    func setupInputOutput()
    {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            if #available(iOS 11.0, *) {
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer()
    {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession()
    {
        captureSession.startRunning()
    }
    
    fileprivate func swapCamera() {
        
        
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        var newDevice: AVCaptureDevice?
        if input.device.position == .back
        {
            newDevice = frontCamera
        }
        else
        {
            newDevice = backCamera
        }
        
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        captureSession.removeInput(input)
        captureSession.addInput(deviceInput)
    }
    
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on)
            {
                device.torchMode = AVCaptureDevice.TorchMode.off
                self.ImfFlshLIght.image = UIImage(named: "flash-off1")
                self.ImfFlshLIght.image = ImfFlshLIght.image?.withRenderingMode(.alwaysTemplate)
                ImfFlshLIght.tintColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
            }
            else
            {
                do
                {
                    try device.setTorchModeOn(level: 1.0)
                    self.ImfFlshLIght.image = UIImage(named: "flash-on1")
                    self.ImfFlshLIght.image = ImfFlshLIght.image?.withRenderingMode(.alwaysTemplate)
                    ImfFlshLIght.tintColor = #colorLiteral(red: 0.6156862745, green: 0.4666666667, blue: 0.9960784314, alpha: 1)
                }
                catch
                {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        }
        catch
        {
            print(error)
        }
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate
{
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
   {
       if let error = error
        {
         print("error occured : \(error.localizedDescription)")
        }

        if let dataImage = photo.fileDataRepresentation()
         {
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)

           self.GetImage = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
           print("Image Final:- \(self.GetImage)")
            
            self.ArrImageSelected.append(GetImage)
            self.hideOrShowPreview()
         }
        else
         {
             print("some error here")
         }
       }
    
    func hideOrShowPreview(){
           if ArrImageSelected.count == self.photosCountLimit{
               btnCount.isUserInteractionEnabled = false
               btnCount.alpha = 0.5
            
           }
           else{
               btnCount.isUserInteractionEnabled = true
               btnCount.alpha = 1
           }
           
           if ArrImageSelected.count > 0{
               self.btnCount.isHidden = false
               self.ImageView.isHidden = false
               self.AddImageView.isHidden = false
               self.CatchImage.image = self.ArrImageSelected.last
               self.btnCount.setTitle("\(self.ArrImageSelected.count)", for: .normal)
           }
           else{
               self.btnCount.isHidden = true
               self.ImageView.isHidden = true
               self.AddImageView.isHidden = true
           }
       }
   }

extension CameraVC
{
    fileprivate func getAllGalleryPhotos() {
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                let fetchOption = PHFetchOptions()
                self.arrAllGalleryImage = PHAsset.fetchAssets(with: self.assetMediaType, options: fetchOption)
                DispatchQueue.main.async {
                    self.CollectioView.reloadData()
                }
            case .denied, .restricted: break
            
           // appDelegate.showToast(title: "Denied", message: "Permission is denied or restricted of access gallery photo", ImageName: <#T##String#>)
            
            case .notDetermined: break //ActivityClick.addAlert(Title: "Permission is notDetermined of access gallery photo", type: .error)
            default: break
            }
        }
    }
    
    func fetchImageToGallery(assets:PHAsset,complition: @escaping(UIImage) -> ()) {
        let option = PHImageRequestOptions()
        option.version = .original
        PHImageManager.default().requestImage(for: assets, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: option) { (image, _) in
            guard let image = image else { return }
            complition(image)
        }
    }
    
    @objc func tapDetected()
    {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CameraBaseVC") as! CameraBaseVC
        controller.ArrImageSelectedFinal = self.ArrImageSelected
        self.ArrImageSelected.removeAll()
        self.ArrImageIndex.removeAll()
        navigationController?.pushViewController(controller, animated: false)
    }
}

extension CameraVC : UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
     {
        return self.arrAllGalleryImage.count
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

       let cell = CollectioView.dequeueReusableCell(withReuseIdentifier: "GalleryNewCell", for: indexPath) as! GalleryNewCell
        
        cell.GalleryImage.layer.cornerRadius = 3
        cell.GalleryImage.clipsToBounds = true
        cell.GallerySelectImage.isHidden = true
        
        let imageAsset = self.arrAllGalleryImage[indexPath.row]
              
        cell.GalleryImage.fetchImageToGallery(assets: imageAsset, targetSize: cell.frame.size)
        
        cell.btnSelect.addTarget(self, action: #selector(ImageSelectddd(sender:)), for: .touchUpInside)
       cell.btnSelect.tag = indexPath.row

        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//    {
//        DispatchQueue.main.async {
//
//            let indexPath = IndexPath(row:  indexPath.row, section: 0)
//            if let cell = self.CollectioView.cellForItem(at: indexPath) as? GalleryNewCell
//            {
//                if cell.GallerySelectImage.isHidden == true
//                {
//                    cell.GallerySelectImage.isHidden = false
//
//                    self.fetchImageToGallery(assets: self.arrAllGalleryImage[indexPath.row]) { (image) in
//                        self.ArrImageSelected.append(image)
//                        self.ArrImageIndex.append(indexPath.row)
//                        print("Select Index Add :- \(self.ArrImageIndex)")
//                        print("Select Image Add :- \(self.ArrImageSelected)")
//                        self.hideOrShowPreview()
//                    }
//                }
//                else
//                {
//                    cell.GallerySelectImage.isHidden = true
//
//                    if let index = self.ArrImageIndex.firstIndex(of: indexPath.row)
//                    {
//                        self.ArrImageIndex.remove(at: index)
//                        self.ArrImageSelected.remove(at: index)
//                        self.hideOrShowPreview()
//                    }
//                    print("Select Index Remove :- \(self.ArrImageIndex)")
//                    print("Select Image Remove :- \(self.ArrImageSelected)")
//                }
//
//            }
//
//        }
//
//    }
  
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if arrAllGalleryImage.count > 0 {
//            collectionView.scrollToItem(at: IndexPath(item:arrAllGalleryImage.count - 1, section: 0), at: .top, animated: false)
//        }
//    }
    
    
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }

    // UIImagePickerControllerDelegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func ImageSelectddd(sender: UIButton)
    {
        DispatchQueue.main.async {
            
            print("ImageSelectPressed !")
            let indexPath = IndexPath(row:  sender.tag, section: 0)
            
            if let cell = self.CollectioView.cellForItem(at: indexPath) as? GalleryNewCell
            {
                if cell.GallerySelectImage.isHidden == true
                {
                    cell.GallerySelectImage.isHidden = false
                    
                    self.fetchImageToGallery(assets: self.arrAllGalleryImage[sender.tag]) { (image) in
                        self.ArrImageSelected.append(image)
                        self.ArrImageIndex.append(sender.tag)
                        print("Select Index Add :- \(self.ArrImageIndex)")
                        print("Select Image Add :- \(self.ArrImageSelected)")
                        self.hideOrShowPreview()
                    }
                }
                else
                {
                    cell.GallerySelectImage.isHidden = true
                    
                    if let index = self.ArrImageIndex.firstIndex(of: sender.tag)
                    {
                        self.ArrImageIndex.remove(at: index)
                        self.ArrImageSelected.remove(at: index)
                        self.hideOrShowPreview()
                    }
                    
                    print("Select Index Remove :- \(self.ArrImageIndex)")
                    print("Select Image Remove :- \(self.ArrImageSelected)")
                }
                
            }
        }
        
    }
}



extension UIImageView {
    
    func fetchImageToGallery(assets:PHAsset, targetSize:CGSize) {
        let option = PHImageRequestOptions()
        option.version = .original
        PHImageManager.default().requestImage(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: option) { (image, _) in
            guard let image = image else { return }
            self.contentMode = .scaleAspectFill
            self.image = image
        }
    }
    
    @IBInspectable var imageColor : UIColor? {
        get {
            return self.imageColor
        }set {
            self.image = self.image?.withRenderingMode(.alwaysTemplate)
            self.tintColor = newValue
        }
    }
    
}


extension CameraVC
{
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            if GalleryHeight.constant == 75
            {
                self.GalleryHeight.constant = 400
                if let layout = CollectioView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical  // .horizontal
                }
            }
            else
            {
                self.GalleryHeight.constant = 75
                if let layout = CollectioView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal  // .horizontal
                }

            }
        default:
            self.GalleryHeight.constant = 75
            if let layout = CollectioView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal  // .horizontal
            }

            break
        }
    }

    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let translation = recognizer.translation(in: self.GalleryMain)
            print("translation began \(translation)")
        case .changed:
            let translation = recognizer.translation(in: self.GalleryMain)
            print("translation changed \(translation)")
        case .ended:
             let translation = recognizer.translation(in: self.GalleryMain)
             print("translation ended \(translation)")
        default:
            break
        }

    }
}
