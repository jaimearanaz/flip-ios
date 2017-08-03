//
//  MainPresenterDelegate.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc enum GameSource: Int {
    case camera
    case facebook
    case twitter
    case unkown
}

@objc enum GameSize: Int {
    case small = 12
    case medium = 18
    case big = 24
    case unkown
}

@objc protocol MainPresenterDelegate: FLPBasePresenterDelegate {
    
    func didSelectOptions(source: GameSource, size: GameSize)
}
