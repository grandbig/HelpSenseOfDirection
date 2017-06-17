//
//  ViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/06/18.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    private var placesClient: GMSPlacesClient!
    private var zoomLevel: Float = 15.0
    private var firstView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = GMSMapViewType.normal
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.delegate = self
        
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.distanceFilter = 50
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.delegate = self
        
        self.placesClient = GMSPlacesClient.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: GMSMapViewDelegate
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        print(self.mapView.myLocation ?? "not found")
        
        return false
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (!self.firstView) {
            let camera = GMSCameraPosition.camera(withTarget: (locations.last?.coordinate)!, zoom: self.zoomLevel)
            self.mapView.camera = camera
            self.locationManager?.stopUpdatingLocation()
            self.firstView = true
        }
    }
}

