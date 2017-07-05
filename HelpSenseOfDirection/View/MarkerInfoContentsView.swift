//
//  MarkerInfoContentsView.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/04.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class MarkerInfoContentsView: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibViewSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.xibViewSet()
    }
    
    internal func xibViewSet() {
        if let view = Bundle.main.loadNibNamed("MarkerInfoContentsView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
    /**
     データの設定処理
     
     - parameter title: タイトル
     - parameter detail: 詳細説明
     - parameter image: 画像
     */
    func setData(title: String?, detail: String?, image: UIImage?) {
        self.title.text = title ?? "-"
        self.detail.text = detail ?? "-"
        self.imageView.image = image ?? UIImage(named: "NoImageIcon")
    }
}
