//
//  Score.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

@objc class Score: NSObject {
    
    var time: TimeInterval = 0
    var errors = 0
    var penalization: TimeInterval = 0
    var finalTime: TimeInterval = 0
}
