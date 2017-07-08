//
//  Mark.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/01.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

/**
 目印
 */
class RealmMark: Object {
    dynamic var id: Int = 0
    dynamic var title: String = ""
    dynamic var detail: String = ""
    dynamic var image: NSData = NSData()
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var created: Double = Date().timeIntervalSince1970
    dynamic var updated: Double = Date().timeIntervalSince1970
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // インデックスの設定
    override static func indexedProperties() -> [String] {
        return ["title"]
    }
}
