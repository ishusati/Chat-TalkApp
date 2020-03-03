

import UIKit

class ImageVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet var imageview: UIImageView!
    
    //MARK:- VARIABLE
    var imageURLString: String?
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.imageview.setImage(url: URL(string: imageURLString ?? ""))
    }
    
    //MARK:- VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool) {
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
    @IBAction func DoubleTapGesture(_ sender: UITapGestureRecognizer)
    {
      if scrollview.zoomScale == 1
      {
         scrollview.zoom(to: zoomRectForScale(scale: scrollview.maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
             return
        }
        
      scrollview.setZoomScale(1, animated: true)
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
       var zoomRect = CGRect.zero
       zoomRect.size.height = imageview.frame.size.height / scale
       zoomRect.size.width  = imageview.frame.size.width  / scale
       let newCenter = imageview.convert(center, from: scrollview)
       zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
       zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
       return zoomRect
     }
    
    @IBAction func btnClose(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      modalTransitionStyle = .crossDissolve
      modalPresentationStyle = .overFullScreen
    }
}

extension ImageVC : UIScrollViewDelegate
{
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageview
  }
}
