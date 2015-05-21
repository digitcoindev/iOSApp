import UIKit
import CoreLocation

class GoogleMap: UIViewController , CLLocationManagerDelegate
{
    var camera : GMSCameraPosition!
    var mapView : GMSMapView!
    var myMarker = GMSMarker()

    let locationManager = CLLocationManager()
    
    var showMe = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if State.fromVC != SegueToGoogleMap
        {
            State.fromVC = SegueToGoogleMap
        }
        
        State.currentVC = SegueToGoogleMap
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else
        {
            println("Location service disabled");
        }
        camera = GMSCameraPosition.cameraWithLatitude(0,
            longitude:0, zoom:1)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        mapView.settings.compassButton = true
        
        self.view = mapView
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Map" )

    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        if showMe
        {
            mapView.camera = GMSCameraPosition.cameraWithLatitude(locValue.latitude,
            longitude:locValue.longitude, zoom:16)
            
            
            myMarker.position = locValue
            myMarker.snippet = "You are here!"
            myMarker.appearAnimation = kGMSMarkerAnimationPop
            myMarker.map = mapView
            
            showMe = false
        }

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
