//
//  MainViewControllerDelegate.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc protocol MainViewControllerDelegate: FLPBaseViewControllerDelegate {

    func startLoadingState()
    
    func stopLoadingState()
    
    func showRecords(_ records: Records)
    
    func showSourceView()
    
    func showMessage(_ message: String)
}
