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
import SwiftyJSON

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    private var placesClient: GMSPlacesClient!
    private var goalMarker: GMSMarker = GMSMarker()
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
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let view = UINib(nibName: "MarkerInfoContentsView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView else {
            return nil
        }
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.mapView.selectedMarker = nil
        guard let myCoordinate = self.mapView.myLocation?.coordinate else {
            return
        }
        let direction = Direction()
        direction.getRoutes(from: myCoordinate, to: self.goalMarker.position) { (json) in
            self.drawPolyline(steps: json)
        }
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
                self.putMarker(title: nil, latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.changeCameraPosition(coordinate: coordinate)
            }
        }) { 
            // キャンセルした場合
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.mapClear()
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
    private func putMarker(title: String?, latitude: Double, longitude: Double) {
        if self.goalMarker.map != nil {
            // 既にマップ上にマーカが配置されている場合は削除
            self.goalMarker.map = nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: coordinate)
        marker.title = title
        marker.map = self.mapView
        self.goalMarker = marker
    }
    
    /**
     現在地と指定した場所の両方が入るようにマップの縮尺を変更する処理
     
     - parameter coordinate: 場所
     */
    private func changeCameraPosition(coordinate: CLLocationCoordinate2D) {
        guard let myLocation = self.mapView.myLocation?.coordinate else {
            return
        }
        let bounds = GMSCoordinateBounds(coordinate: myLocation, coordinate: coordinate)
        let margin: CGFloat = 50.0
        guard let camera = self.mapView.camera(for: bounds, insets: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)) else {
            return
        }
        self.mapView.camera = camera
    }
    
    /**
     マップ上に線を描画する処理
     
     - parameter steps: ルート情報
     */
    private func drawPolyline(steps: JSON) {
        let path = GMSMutablePath()
        let startLocation = steps[0]["start_location"]
        guard let startLat = startLocation["lat"].double, let startLng = startLocation["lng"].double else {
            return
        }
        path.add(CLLocationCoordinate2D(latitude: startLat, longitude: startLng))
        steps.array?.forEach { (step) in
            guard let stepLat = step["end_location"]["lat"].double, let stepLng = step["end_location"]["lng"].double else {
                return
            }
            path.add(CLLocationCoordinate2D(latitude: stepLat, longitude: stepLng))
        }
        let line = GMSPolyline(path: path)
        line.strokeWidth = 3.0
        line.map = self.mapView
    }
    
    /**
     マップ上の図形描画などを除去する処理
     */
    private func mapClear() {
        self.mapView.clear()
    }
}
