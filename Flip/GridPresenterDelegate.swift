//
//  GridPresenterDelegate.swift
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc protocol GridPresenterDelegate: FLPBasePresenterDelegate {
 
    func didSelectExit()
    
    func gameFinished(withTime time: TimeInterval, numberOferrors: Int)
}
