import UIKit
import CoreLocation

class GoogleMap: AbstractViewController , CLLocationManagerDelegate
{
    var camera : GMSCameraPosition!
    var map : GMSMapView!
    var myMarker = GMSMarker()

    let locationManager = CLLocationManager()
    
    var showMe = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        State.fromVC = SegueToGoogleMap
        State.currentVC = SegueToGoogleMap
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else {
            print("Location service disabled");
        }
        camera = GMSCameraPosition.cameraWithLatitude(0,
            longitude:0, zoom:1)
        map = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        map.settings.compassButton = true
        
        self.view = map
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        if showMe {
            map.camera = GMSCameraPosition.cameraWithLatitude(locValue.latitude,
            longitude:locValue.longitude, zoom:16)
            
            
            myMarker.position = locValue
            myMarker.snippet = "YOUR_POSITION".localized()
            myMarker.appearAnimation = kGMSMarkerAnimationPop
            myMarker.map = map
            
            showMe = false
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
