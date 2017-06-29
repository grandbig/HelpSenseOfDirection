//
//  CustomGMSMarker.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/06/29.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class CustomGMSMarker: GMSMarker {
    /// マーカタイプ
    public var type: MarkerType?
    
    /// 初期化
    override init() {
        super.init()
    }
    
    /**
     マーカの位置を設定する処理
     
     - parameter position:　位置
     */
    func setMarkerPosition(_ position: CLLocationCoordinate2D) {
        self.position = position
    }
    
    /**
     マーカのタイプを設定する処理
     
     - parameter type: マーカのタイプ
     */
    func setMarkerType(_ type: MarkerType) {
        self.type = type
    }
}
