//
//  MainViewControllerDelegate.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class MainMessage: NSObject {
    
    var message = ""
    var leftTitle = ""
    var rightTitle = ""
    
    init(message: String, leftTitle: String, rightTitle: String) {
        
        super.init()
        
        self.message = message
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
    }
}

@objc protocol MainViewControllerDelegate: FLPBaseViewControllerDelegate {

    func startLoadingState()
    
    func stopLoadingState()
    
    func showRecords(_ records: Records)
    
    func showSourceView(withAnimation: Bool)
    
    func showMessage(_ message: String)
    
    func showMessage(_ message: MainMessage, leftOption: (() -> Void), rightOption: (() -> Void))
}
