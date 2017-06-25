//
//  Geocoding.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/06/19.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
import Darwin

class Geocoding {
    
    /// API Key
    private var apiKey: String = String()
    /// Geocoding APIのベースURL
    private let baseURL: String = "https://maps.googleapis.com/maps/api/geocode/json?language=ja"
    
    /// 初期化処理
    init() {
        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let apiKey = dic["googleGeocodingApiKey"] as? String {
                    self.apiKey = apiKey
                }
            }
        }
    }
    
    /**
     ジオコーディング
     
     - parameter address: 住所
     - parameter completion: 緯度/経度を返すcallback
     */
    func geocoding(address: String, completion: @escaping ((CLLocationCoordinate2D) -> Void)) {
        let requestURL = "\(baseURL)&key=\(String(describing: self.apiKey))"
        Alamofire.request(requestURL, method: .get, parameters: ["address": address], encoding: URLEncoding.default, headers: nil).responseJSON { response in
            let json = JSON(response.result.value as Any)
            
            guard let latitude = json["results"][0]["geometry"]["location"]["lat"].double else {
                return
            }
            
            guard let longitude = json["results"][0]["geometry"]["location"]["lng"].double else {
                return
            }
            
            completion(CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude))
        }
    }
    
}
