//
//  ScoreViewControllerDelegate.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc protocol ScoreViewControllerDelegate: FLPBaseViewControllerDelegate {
    
    func showScore(_ score: Score, isNewRecord: Bool)
}
