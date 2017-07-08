//
//  MarkManager.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/01.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMarkManager {
    
    /// シングルトン
    static let sharedInstance = RealmMarkManager()
    
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
            let mark = RealmMark()
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
                realm.create(RealmMark.self, value: mark, update: false)
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
    
    /**
     保存したマーク全てを取得する処理
     
     - returns: 全てのマーク
     */
    func selectAll() -> Results<RealmMark>? {
        do {
            let marks = try Realm().objects(RealmMark.self).sorted(byKeyPath: "id")
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
    func selectById(_ id: Int) -> RealmMark? {
        do {
            let realm = try Realm()
            let mark = realm.object(ofType: RealmMark.self, forPrimaryKey: id)
            return mark
        } catch _ as NSError {
            return nil
        }
    }
    
    /**
     指定したIDのマーカを削除する処理
     
     - parameter id: ID
     */
    func delete(_ id: Int) {
        if let mark = selectById(id) {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(mark)
                }
            } catch let error as NSError {
                print("Error: code - \(error.code), description - \(error.description)")
            }
        }
    }
    
    /**
     保存した全てのマークを削除する処理
     */
    func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
}
