//
//  SizeViewDelegate.swift
//  Flip
//
//  Created by Jaime on 12/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc protocol SizeViewDelegate {
    
    func didSelectSmall()
    
    func didSelectMedium()
    
    func didSelectBig()
    
    func didSelectShowSource()
}
