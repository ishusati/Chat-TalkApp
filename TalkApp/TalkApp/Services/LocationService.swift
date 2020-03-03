
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
  
  private lazy var manager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.delegate = self
    return manager
  }()
  private var hasSentLocation = false
  var completion: CompletionObject<Response>?
  
  func getLocation(_ closure: CompletionObject<Response>? ) {
    completion = closure
    hasSentLocation = false
    if CLLocationManager.authorizationStatus() == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
    manager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard !hasSentLocation else {
      manager.stopUpdatingLocation()
      return
    }
    if let location = locations.last?.coordinate {
      completion?(.location(location))
      hasSentLocation = true
      manager.stopUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .denied {
      completion?(.denied)
    }
  }
}

extension LocationService {
  
  enum Response {
    case denied
    case location(CLLocationCoordinate2D)
  }
}
