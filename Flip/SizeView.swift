//
//  SizeView.swift
//  Flip
//
//  Created by Jaime on 12/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class SizeView: UIViewFromNib {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var small: UIButton!
    @IBOutlet var medium: UIButton!
    @IBOutlet var big: UIButton!
    @IBOutlet var showSource: UIButton!
    
    var delegate: SizeViewDelegate!
    
    // MARK: - Action methods
    
    @IBAction func didSelectSmall() {
        
        delegate.didSelectSmall()
    }
    
    @IBAction func didSelectMedium() {
        
        delegate.didSelectMedium()
    }
    
    @IBAction func didSelectBig() {
        
        delegate.didSelectBig()
    }
    
    @IBAction func didSelectShowSource() {
     
        delegate.didSelectShowSource()
    }

}
