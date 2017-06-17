//
//  ViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/06/18.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = GMSMapViewType.normal
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

