//
//  MarkManager.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/01.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

class MarkManager {
    
    /// シングルトン
    static let sharedInstance = MarkManager()
    
    /// イニシャライザ
    init() {
        
    }
    
    /**
     マークをRealmに保存する処理
     
     - parameter title: タイトル
     - parameter detail: 詳細情報
     - parameter image: 画像
     - parameter latitude: 緯度
     - parameter longitude: 経度
     */
    func createMark(title: String, detail: String?, image: NSData?, latitude: Double, longitude: Double) {
        do {
            let realm = try Realm()
            let mark = Mark()
            mark.id = (selectAll()?.last != nil) ? ((selectAll()?.last?.id)! + 1) : 0
            mark.title = title
            if let markDetail = detail {
                mark.detail = markDetail
            }
            if let markImage = image {
                mark.image = markImage
            }
            mark.latitude = latitude
            mark.longitude = longitude
            
            // Realmへのオブジェクトの書き込み
            try realm.write {
                realm.create(Mark.self, value: mark, update: false)
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
    
    /**
     保存したマーク全てを取得する処理
     
     - returns: 全てのマーク
     */
    func selectAll() -> Results<Mark>? {
        do {
            let marks = try Realm().objects(Mark.self).sorted(byKeyPath: "id")
            return marks
        } catch _ as NSError {
            return nil
        }
    }
    
    /**
     指定したIDに紐づくマークを取得する処理
     
     - parameter id: ID
     - returns: マーク
     */
    func selectById(_ id: Int) -> Mark? {
        do {
            let realm = try Realm()
            let marks = realm.objects(Mark.self).filter("id == '\(id)'")
            return marks.first
        } catch _ as NSError {
            return nil
        }
    }
}
