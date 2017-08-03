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
    
    // MARK: - Lifecycle methods
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        localizeTexts()
    }
    
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

    // MARK: - Private methods
    
    fileprivate func localizeTexts() {
        
        title.text =  NSLocalizedString("MAIN_SELECT_GRID", comment: "Title for size screen")
        
        small.setTitle(NSLocalizedString("MAIN_SMALL", comment: "Button for small size"), for: .normal)
        medium.setTitle(NSLocalizedString("MAIN_MEDIUM", comment: "Button for medium size"), for: .normal)
        big.setTitle(NSLocalizedString("MAIN_BIG", comment: "Button for big size"), for: .normal)
        
        showSource.setTitle(NSLocalizedString("MAIN_SOURCE", comment: "Button to change source"), for: .normal)
    }
}
