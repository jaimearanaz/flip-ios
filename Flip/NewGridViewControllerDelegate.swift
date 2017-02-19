//
//  NewGridViewControllerDelegate.swift
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc protocol NewGridViewControllerDelegate: FLPBaseViewControllerDelegate {
    
    @objc (showItems:)
    func showItems(_ items: [GridCell])
}
