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
    private var initView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // GoogleMapの初期化
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = GMSMapViewType.normal
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.delegate = self
        
        // 位置情報関連の初期化
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
        
        if !self.initView {
            // 初期描画時のマップ中心位置の移動
            let camera = GMSCameraPosition.camera(withTarget: (locations.last?.coordinate)!, zoom: self.zoomLevel)
            self.mapView.camera = camera
            self.locationManager?.stopUpdatingLocation()
            self.initView = true
        }
    }
    
    // MARK: Button Action
    @IBAction func start(_ sender: Any) {
        self.showTextComfirm(title: "確認", message: "目的地を入力してください", okCompletion: { (address: String) in
            // OKした場合
            let geo = Geocoding.init()
            geo.geocoding(address: address) { (coordinate: CLLocationCoordinate2D) in
                print("\(coordinate.latitude), \(coordinate.longitude)")
                self.putMarker(title: "目的地", latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }) { 
            // キャンセルした場合
        }
    }
    
    // MARK: Other
    /**
     TextField付き確認モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter okCompletion: OKタップ時のCallback
     - parameter cancelCompletion: Cancelタップ時のCallback
     */
    private func showTextComfirm(title: String, message: String, okCompletion: @escaping ((String) -> Void), cancelCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { _ in
            if let enteredText = alert.textFields?[0].text {
                okCompletion(enteredText)
                return
            }
            self.showAlert(title: "Alert", message: "Please input the text.", completion: {
                cancelCompletion()
            })
        }
        let cancelAction = UIAlertAction.init(title: "キャンセル", style: UIAlertActionStyle.cancel) { _ in
            cancelCompletion()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField { _ in
        }
        present(alert, animated: true, completion: nil)
    }
    
    /**
     警告モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter completion: OKタップ時のCallback
     */
    private func showAlert(title: String, message: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { _ in
            completion()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     マップにマーカを設置する処理
     
     - parameter title: マーカのタイトル
     - parameter latitude: 緯度
     - parameter longitude: 経度
     */
    private func putMarker(title: String, latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: coordinate)
        marker.title = title
        marker.map = self.mapView
    }
}
