//
//  MainPresenterDelegate.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

// TODO: rename to PhotoSource
@objc enum GameSource: Int {
    case camera
    case facebook
    case twitter
}

// TODO: rename to GridSize
@objc enum GameSize: Int {
    case small = 12
    case medium = 18
    case big = 24
}

@objc protocol MainPresenterDelegate: FLPBasePresenterDelegate {
    
    func didSelectOptions(source: GameSource, size: GameSize)
}
