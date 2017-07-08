//
//  CreateMarkerViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/02.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CreateMarkerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeTitleTextField: UITextField!
    @IBOutlet weak var placeTextArea: UIPlaceHolderTextView!
    private var markManager = RealmMarkManager.sharedInstance
    var markCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.placeTextArea.placeHolder = "詳細説明を入力"
        self.placeTextArea.placeHolderColor = UIColor(red: 0.75, green: 0.75, blue: 0.77, alpha: 1.0)
        self.placeTitleTextField.delegate = self
        self.createToolBar()
        
        // RealmSwift関連の初期化処理
        self.markManager = RealmMarkManager.init()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.placeImageView.image = image
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Button Action
    @IBAction func okAction(_ sender: Any) {
        self.showConfirm(title: "確認", message: "目印マーカの情報を保存しますか？", okCompletion: {
            // OKタップ時
            if let markCoordinate = self.markCoordinate {
                // 位置情報がある場合
                var imageData: NSData?
                let title: String = self.placeTitleTextField.text ?? ""
                let latitude = markCoordinate.latitude
                let longitude = markCoordinate.longitude
                let markId = (self.markManager.selectAll()?.last != nil) ? ((self.markManager.selectAll()?.last?.id)! + 1) : 0
                if let image = self.placeImageView.image {
                    imageData = NSData.init(data: UIImageJPEGRepresentation(image, 1.0)!)
                }
                // データの保存
                self.markManager.createMark(title: title, detail: self.placeTextArea.text, image: imageData, latitude: latitude, longitude: longitude)
                // 遷移元ViewControllerの取得
                guard let nav = self.presentingViewController as? UINavigationController, let vc = nav.viewControllers[nav.viewControllers.count - 1] as? ViewController else {
                    return
                }
                // マップに目印マーカを描画
                vc.putPointMarker(title: nil, coordinate: markCoordinate, id: markId)
                // 画面遷移
                self.dismiss(animated: true, completion: {
                })
            }
        }) {
            // キャンセルタップ時
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    
    /**
     Viewのタップアクション
     
     - parameter touches: タッチ
     - parameter event: イベント
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches where touch.view?.tag == 1 {
            // UIImageViewをタップした場合
            self.pickImageFromCamera()
        }
    }
    
    // MARK: Other
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.camera
            present(controller, animated: true, completion: nil)
        }
    }
    
    /// キーボード用ツールバーの生成処理
    func createToolBar() {
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        kbToolBar.barStyle = UIBarStyle.default
        kbToolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        
        self.placeTextArea.inputAccessoryView = kbToolBar
    }
    
    /// ツールバーのDONEボタンタップ時の処理
    func doneButtonTapped() {
        self.view.endEditing(true)
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
}
