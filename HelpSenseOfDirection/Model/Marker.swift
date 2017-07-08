//
//  Marker.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/09.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

/**
 Marker DTO
 */
class Marker {
    internal var id: Int?
    internal var type: MarkerType?
    
    init(id: Int?, type: MarkerType?) {
        self.id = id
        self.type = type
    }
}
