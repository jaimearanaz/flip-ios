//
//  RecordsView.swift
//  Flip
//
//  Created by Jaime on 11/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class RecordsView: UIViewFromNib {
 
    var delegate: RecordsViewDelegate!
    
    // MARK: Action methods
    
    @IBAction func didSelectStartGame() {
     
        delegate.didSelectStartGame()
    }
}
