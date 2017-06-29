//
//  MarkerType.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/06/29.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

enum MarkerType: Int {
    case start = 0
    case mark
    case goal
    
    static let defaultMarkerType = MarkerType.mark
    init() {
        self = MarkerType.defaultMarkerType
    }
}
