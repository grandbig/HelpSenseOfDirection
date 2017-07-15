//
//  AnnotationViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/15.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import Gecco

class AnnotationViewController: SpotlightViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelConstraintY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateLabel(_ text: String, blackColor: Bool = false) {
        self.label.text = text
        if blackColor {
            self.label.textColor = UIColor.black
        }
    }
}
