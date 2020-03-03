
import UIKit
import MapKit

class MapVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet var MapView: MKMapView!
    
    //MARK:- VARIABLE
   var locationString: String?
    
    //MARK:- VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let location = locationString?.location else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        MapView.addAnnotation(annotation)
        MapView.showAnnotations(MapView.annotations, animated: false)
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
