//
//  ViewController+GMSMapView.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/10.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

extension ViewController: GMSMapViewDelegate {
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if self.goalMarker.map != nil {
            // 目的地マーカを設定した場合のみ途中ポイントマーカを設定可能
            self.showConfirm(title: "確認", message: "ここに目印マーカを配置しますか？", okCompletion: {
                // OKタップ時
                self.markCoordinate = coordinate
                // 画面遷移
                self.performSegue(withIdentifier: "showPopupSegue", sender: nil)
            }) {
                // キャンセルタップ時は何もしない
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let cMarker = marker as? CustomGMSMarker else {
            return nil
        }
        if cMarker.type == MarkerType.point, let cMarkerId = cMarker.id {
            // 目印マーカの場合
            let mark = self.markManager.selectById(cMarkerId)
            var image = UIImage(named: "NoImageIcon")
            if let imageData = mark?.image as Data? {
                image = UIImage(data: imageData)
            }
            let view = MarkerInfoContentsView(frame: CGRect(x: 0, y: 0, width: 250, height: 265))
            view.setData(title: mark?.title, detail: mark?.detail, image: image)
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.mapView.selectedMarker = nil
    }
}
