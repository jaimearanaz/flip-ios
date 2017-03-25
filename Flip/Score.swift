//
//  Score.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

enum GamePenalization: Int {
    case small = 3
    case medium = 2
    case big = 1
}

@objc class Score: NSObject {
    
    var time: TimeInterval = 0
    var errors = 0
    var penalization: TimeInterval = 0
    var finalTime: TimeInterval = 0
}
