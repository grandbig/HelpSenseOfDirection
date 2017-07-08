//
//  SlideMenuViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/01.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RealmSwift

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var markManager = RealmMarkManager.sharedInstance
    private var marks: Results<RealmMark>?
    internal var markersOnMap: [CustomGMSMarker]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.marks = self.markManager.selectAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 指定したIDのデータを削除
            guard let markId = marks?[indexPath.row].id else {
                return
            }
            self.markManager.delete(markId)
            self.marks = self.markManager.selectAll()
            // テーブルからの削除
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let markers = self.markersOnMap {
                for marker in markers where marker.id == markId {
                    marker.map = nil
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marks?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MarkCell", for: indexPath)
        cell.textLabel?.text = self.marks?[indexPath.row].title ?? "-"
        
        var image = UIImage(named: "NoImageIcon")
        if let imageData = self.marks?[indexPath.row].image as Data? {
            image = UIImage(data: imageData)
        }
        cell.imageView?.image = image
        
        return cell
    }
    
    // MARK: Button Action
    @IBAction func deleteAll(_ sender: Any) {
        self.showConfirm(title: "確認", message: "全ての目印を削除しますか？", okCompletion: {
            self.markManager.deleteAll()
            if let markers = self.markersOnMap {
                for marker in markers {
                    marker.map = nil
                }
            }
        }) {
        }
    }
    
    // MARK: Other
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
