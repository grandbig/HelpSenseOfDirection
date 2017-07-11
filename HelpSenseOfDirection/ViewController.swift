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
import Gecco

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var startButtonBottomConstraint: NSLayoutConstraint!
    internal var locationManager: CLLocationManager?
    internal var currentLocation: CLLocationCoordinate2D?
    internal var goalMarker: GMSMarker = GMSMarker()
    internal var zoomLevel: Float = 15.0
    internal var initView: Bool = false
    internal var markManager = RealmMarkManager.sharedInstance
    internal var tutorialStep: Int = 0
    internal let spotlightViewController: SpotlightViewController = SpotlightViewController()
    internal var markCoordinate: CLLocationCoordinate2D?
    internal var markersOnMap: [CustomGMSMarker]? = [CustomGMSMarker]()
    private var placesClient: GMSPlacesClient!
    private var routePath: GMSPolyline = GMSPolyline()
    private var isTutorial: Bool = false
    
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
        
        if let marks = self.markManager.selectAll() {
            if marks.count > 0 {
                // 既にマーカを保存している場合は全て削除する
                self.markManager.deleteAll()
            }
        }
        
        self.spotlightViewController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.checkTutorialState() {
            // チュートリアルが完了していない場合
            self.tutorial(step: self.tutorialStep)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let marker = Marker(id: nil, type: MarkerType.start)
                self.putMarker(title: "スタート地点", coordinate: myCurrentLocation, iconName: "StartIcon", marker: marker, completion: { _ in })
                self.putGoalMarker(title: "ゴール地点", coordinate: coordinate)
                self.changeCameraPosition(coordinate: coordinate)
                // スタート地点からゴール地点までの道のりを描画
                let direction = Direction()
                direction.getRoutes(from: myCurrentLocation, to: self.goalMarker.position) { (json) in
                    self.drawPolyline(steps: json)
                    if !self.checkTutorialState() {
                        // チュートリアルが完了していない場合
                        self.tutorial(step: self.tutorialStep)
                    }
                }
            }
        }) { 
            // キャンセルした場合
            if !self.checkTutorialState() {
                // チュートリアルが完了していない場合
                self.tutorial(step: (self.tutorialStep - 1))
                self.tutorialStep -= 1
            }
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
        } else if segue.identifier == "slideMenuSegue" {
            if let slideMenuViewController = segue.destination as? SlideMenuViewController {
                slideMenuViewController.markersOnMap = self.markersOnMap
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
            self.showAlert(title: "アラート", message: "入力してください", completion: {
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
    internal func showConfirm(title: String, message: String, okCompletion: @escaping (() -> Void), cancelCompletion: @escaping (() -> Void)) {
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
    internal func showAlert(title: String, message: String, completion: @escaping (() -> Void)) {
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
     - parameter marker: マーカオブジェクト
     - parameter completion: Callback
     */
    private func putMarker(title: String?, coordinate: CLLocationCoordinate2D, iconName: String?, marker: Marker?, completion: @escaping ((CustomGMSMarker) -> Void)) {
        // マーカの生成
        let cMarker = CustomGMSMarker()
        cMarker.title = title
        cMarker.position = coordinate
        if iconName != nil {
            cMarker.icon = UIImage.init(named: iconName!)
        }
        if let id = marker?.id {
            cMarker.id = id
        }
        if let type = marker?.type {
            cMarker.type = type
        }
        cMarker.map = self.mapView
        self.markersOnMap?.append(cMarker)
        completion(cMarker)
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
        let marker = Marker(id: nil, type: MarkerType.goal)
        self.putMarker(title: title, coordinate: coordinate, iconName: "GoalIcon", marker: marker) { marker in
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
        let marker = Marker(id: id, type: MarkerType.point)
        self.putMarker(title: title, coordinate: coordinate, iconName: "PointIcon", marker: marker) { _ in
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
    
    // MARK: Tutorial
    /**
     チュートリアルの完了を保存する処理
     */
    private func saveFinishTutorial() {
        UserDefaults.standard.set(true, forKey: "isTutorial")
        UserDefaults.standard.synchronize()
    }
    
    /**
     チュートリアルの完了状態を取得する処理
     
     - returns: チュートリアルの完了状態
     */
    private func checkTutorialState() -> Bool {
        return UserDefaults.standard.bool(forKey: "isTutorial")
    }
    
    /**
     チュートリアル表示処理
     
     - parameter step: ステップ
     */
    internal func tutorial(step: Int) {
        let screenSize = UIScreen.main.bounds.size
        let screenHeight = screenSize.height
        present(self.spotlightViewController, animated: true, completion: nil)
        
        switch step {
        case 0:
            let startButtonCenterX = self.startButtonLeftConstraint.constant + self.startButton.frame.size.width/2
            let startButtonCenterY = screenHeight - self.startButtonBottomConstraint.constant - self.startButton.frame.size.height/2
            self.spotlightViewController.spotlightView.appear(Spotlight.Oval(center: CGPoint(x: startButtonCenterX, y: startButtonCenterY), diameter: 50))
        case 1:
            let mapCenterX = self.mapView.frame.size.width/2
            let mapCenterY = screenHeight - self.mapView.frame.size.height/2
            self.spotlightViewController.spotlightView.appear(Spotlight.Oval(center: CGPoint(x: mapCenterX, y: mapCenterY), diameter: 200))
        default:
            break
        }
    }
}
