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
    private var currentLocation: CLLocationCoordinate2D?
    private var placesClient: GMSPlacesClient!
    private var goalMarker: GMSMarker = GMSMarker()
    private var routePath: GMSPolyline = GMSPolyline()
    private var zoomLevel: Float = 15.0
    private var initView: Bool = false
    private var markManager = MarkManager.sharedInstance
    internal var markCoordinate: CLLocationCoordinate2D?
    
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
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if self.goalMarker.map != nil {
            // 目的地マーカを設定した場合のみ途中ポイントマーカを設定可能
            self.showConfirm(title: "確認", message: "ここに目印マーカを配置しますか？", okCompletion: {
                // OKタップ時
                self.markCoordinate = coordinate
                // 画面遷移
                self.performSegue(withIdentifier: "showPopupSegue", sender: nil)
            }) {
                // キャンセルタップ時は何もしない
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let cMarker = marker as? CustomGMSMarker else {
            return nil
        }
        if cMarker.type == MarkerType.point, let cMarkerId = cMarker.id {
            // 目印マーカの場合
            let mark = self.markManager.selectById(cMarkerId)
            var image = UIImage(named: "NoImageIcon")
            if let imageData = mark?.image as Data? {
                image = UIImage(data: imageData)
            }
            let view = MarkerInfoContentsView(frame: CGRect(x: 0, y: 0, width: 250, height: 265))
            view.setData(title: mark?.title, detail: mark?.detail, image: image)
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.mapView.selectedMarker = nil
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !self.initView {
            // 初期描画時のマップ中心位置の移動
            self.currentLocation = locations.last?.coordinate
            let camera = GMSCameraPosition.camera(withTarget: self.currentLocation!, zoom: self.zoomLevel)
            self.mapView.camera = camera
            self.locationManager?.stopUpdatingLocation()
            self.initView = true
        }
    }
    
    // MARK: Button Action
    @IBAction func start(_ sender: Any) {
        self.showTextComfirm(title: "確認", message: "目的地を入力してください", okCompletion: { (address: String) in
            // OKした場合
            self.clearRoutePath()
            let geo = Geocoding.init()
            geo.geocoding(address: address) { (coordinate: CLLocationCoordinate2D) in
                guard let myCurrentLocation = self.currentLocation else {
                    return
                }
                self.putMarker(title: "スタート地点", coordinate: myCurrentLocation, iconName: "StartIcon", id: nil, type: MarkerType.start, completion: { _ in })
                self.putGoalMarker(title: "ゴール地点", coordinate: coordinate)
                self.changeCameraPosition(coordinate: coordinate)
                // スタート地点からゴール地点までの道のりを描画
                let direction = Direction()
                direction.getRoutes(from: myCurrentLocation, to: self.goalMarker.position) { (json) in
                    self.drawPolyline(steps: json)
                }
            }
        }) { 
            // キャンセルした場合
        }
    }
    
    @IBAction func showList(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        storyboard.instantiateViewController(withIdentifier: "SlideMenuViewController")
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "showPopupSegue" {
            if let createMarkerViewController = segue.destination as? CreateMarkerViewController {
                createMarkerViewController.markCoordinate = self.markCoordinate
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
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
     確認モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter okCompletion: OKタップ時のCallback
     - parameter cancelCompletion: Cancelタップ時のCallback
     */
    private func showConfirm(title: String, message: String, okCompletion: @escaping (() -> Void), cancelCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { _ in
            okCompletion()
        }
        let cancelAction = UIAlertAction.init(title: "キャンセル", style: UIAlertActionStyle.cancel) { _ in
            cancelCompletion()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
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
     - parameter coordinate: 位置
     - parameter iconName: アイコン名
     - parameter id: マーカのID
     - parameter type: マーカのタイプ
     - parameter completion: Callback
     */
    private func putMarker(title: String?, coordinate: CLLocationCoordinate2D, iconName: String?, id: Int?, type: MarkerType, completion: @escaping ((CustomGMSMarker) -> Void)) {
        // マーカの生成
        let marker = CustomGMSMarker()
        marker.title = title
        marker.position = coordinate
        if iconName != nil {
            marker.icon = UIImage.init(named: iconName!)
        }
        if id != nil {
            marker.id = id
        }
        marker.type = type
        marker.map = self.mapView
        completion(marker)
    }
    
    /**
     マップに目的地マーカを設置する処理
     
     - parameter title: マーカのタイトル
     - parameter coordinate: 位置
     */
    private func putGoalMarker(title: String?, coordinate: CLLocationCoordinate2D) {
        if self.goalMarker.map != nil {
            // 既にマップ上にマーカが配置されている場合は削除
            self.goalMarker.map = nil
        }
        self.putMarker(title: title, coordinate: coordinate, iconName: "GoalIcon", id: nil, type: MarkerType.goal) { marker in
            self.goalMarker = marker
        }
    }
    
    /**
     マップに目印マーカを設置する処理
     
     - parameter title: マーカのタイトル
     - parameter coordinate: 位置
     - parameter id: マーカのID
     */
    internal func putPointMarker(title: String?, coordinate: CLLocationCoordinate2D, id: Int) {
        self.putMarker(title: title, coordinate: coordinate, iconName: "PointIcon", id: id, type: MarkerType.point) { _ in
        }
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
        self.routePath = GMSPolyline(path: path)
        self.routePath.strokeWidth = 3.0
        self.routePath.map = self.mapView
    }
    
    /**
     マップ上のルートを削除する処理
     */
    private func clearRoutePath() {
        self.routePath.map = nil
    }
    
    /**
     マップ上の図形描画などを除去する処理
     */
    private func mapClear() {
        self.mapView.clear()
    }
}
