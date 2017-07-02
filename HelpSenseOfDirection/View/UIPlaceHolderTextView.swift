//
//  UIPlaceHolderTextView.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/01.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class UIPlaceHolderTextView: UITextView {
    lazy var placeHolderLabel: UILabel = UILabel()
    var placeHolderColor: UIColor = UIColor.lightGray
    var placeHolder: String = ""
    var borderColor: UIColor = UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.0)
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = self.borderColor.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    func setText(text: String) {
        super.text = text
        self.textChanged(notification: nil)
    }
    
    override public func draw(_ rect: CGRect) {
        if self.placeHolder.characters.count > 0 {
            self.placeHolderLabel.frame           = CGRect.init(x: 8.0, y: 24.0, width: self.bounds.size.width, height: -16.0)
            self.placeHolderLabel.lineBreakMode   = NSLineBreakMode.byWordWrapping
            self.placeHolderLabel.numberOfLines   = 0
            self.placeHolderLabel.font            = self.font
            self.placeHolderLabel.backgroundColor = UIColor.clear
            self.placeHolderLabel.textColor       = self.placeHolderColor
            self.placeHolderLabel.alpha           = 0
            self.placeHolderLabel.tag             = 999
            
            self.placeHolderLabel.text = self.placeHolder
            self.placeHolderLabel.sizeToFit()
            self.addSubview(placeHolderLabel)
        }
        
        self.sendSubview(toBack: placeHolderLabel)
        
        if self.text.utf16.count == 0 && self.placeHolder.characters.count > 0 {
            self.viewWithTag(999)?.alpha = 1
        }
        
        super.draw(rect)
    }
    
    public func textChanged(notification: NSNotification?) {
        if self.placeHolder.characters.count == 0 {
            return
        }
        
        if self.text.characters.count == 0 {
            self.viewWithTag(999)?.alpha = 1
        } else {
            self.viewWithTag(999)?.alpha = 0
        }
    }
}
