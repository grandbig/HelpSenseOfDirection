//
//  ViewController+SpotlightControllerView.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/10.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import Gecco

extension ViewController: SpotlightViewControllerDelegate, UIGestureRecognizerDelegate {
    
    // Spotlightをタップした場合
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        
        if isInsideSpotlight {
            switch self.tutorialStep {
            case 0:
                self.spotlightViewController.dismiss(animated: true, completion: {
                    self.startButton.sendActions(for: .touchUpInside)
                    self.tutorialStep += 1
                })
            case 1:
                self.spotlightViewController.dismiss(animated: true, completion: { 
                    self.showAlert(title: "確認", message: "長押しをしてください", completion: {
                        self.tutorial(step: self.tutorialStep)
                    })
                })
            default:
                break
            }
        }
    }
    
    // Spotlightをロングプレスした場合
    func spotlightViewControllerLongPressed(_ viewController: SpotlightViewController, pressPoint: CGPoint, isInsideSpotlight: Bool) {
        
        if isInsideSpotlight {
            switch self.tutorialStep {
            case 1:
                self.spotlightViewController.dismiss(animated: true, completion: {
                    //let zoom = self.mapView.camera.zoom
                    let coordinate = self.mapView.projection.coordinate(for: pressPoint)
                    if self.goalMarker.map != nil {
                        // 目的地マーカを設定した場合のみ途中ポイントマーカを設定可能
                        self.showConfirm(title: "確認", message: "ここに目印マーカを配置しますか？", okCompletion: {
                            // OKタップ時
                            self.markCoordinate = coordinate
                            // 画面遷移
                            self.performSegue(withIdentifier: "showPopupSegue", sender: nil)
                        }) {
                            // キャンセルタップ時
                            // チュートリアルに戻る
                            self.tutorial(step: self.tutorialStep)
                        }
                    }
                })
            default:
                break
            }
        }
    }
}
