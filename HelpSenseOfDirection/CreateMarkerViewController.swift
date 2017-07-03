//
//  CreateMarkerViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/02.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class CreateMarkerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeTitleTextField: UITextField!
    @IBOutlet weak var placeTextArea: UIPlaceHolderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.placeTextArea.placeHolder = "詳細説明を入力"
        self.placeTextArea.placeHolderColor = UIColor(red: 0.75, green: 0.75, blue: 0.77, alpha: 1.0)
        self.placeTitleTextField.delegate = self
        self.createToolBar()
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
        var imageData: NSData?
        if let image = self.placeImageView.image {
            imageData = NSData.init(data: UIImageJPEGRepresentation(image, 1.0)!)
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
        for touch: UITouch in touches {
            if touch.view?.tag == 1 {
                // UIImageViewをタップした場合
                self.pickImageFromCamera()
            }
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
}
