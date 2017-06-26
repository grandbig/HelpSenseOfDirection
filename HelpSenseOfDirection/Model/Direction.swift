//
//  Direction.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/06/25.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class Direction {
    
    /// API Key
    private var apiKey: String = String()
    /// Geocoding APIのベースURL
    private let baseURL: String = "https://maps.googleapis.com/maps/api/directions/json?language=ja&mode=walking"
    
    /// 初期化処理
    init() {
        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let apiKey = dic["googleWebApiKey"] as? String {
                    self.apiKey = apiKey
                }
            }
        }
    }
    
    /**
     目的地までの道順を取得
     
     - parameter from: 開始地点
     - parameter to: 終了地点
     - parameter completion: 道順を返すcallback
     */
    func getRoutes(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping ((JSON) -> Void)) {
        let requestURL = "\(baseURL)&key=\(String(describing: self.apiKey))"
        let parameters = ["origin": "\(from.latitude),\(from.longitude)", "destination": "\(to.latitude),\(to.longitude)"]
        Alamofire.request(requestURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            let json = JSON(response.result.value as Any)
            let steps = json["routes"][0]["legs"][0]["steps"]
            
            completion(steps)
        }
    }
}
