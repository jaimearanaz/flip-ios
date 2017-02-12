//
//  SourceView.swift
//  Flip
//
//  Created by Jaime on 11/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

@objc class SourceView: UIViewFromNib {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var camera: UIButton!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var showRecords: UIButton!
    
    var delegate: SourceViewDelegate!
    
    // MARK: - Lifecycle methods
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        localizeTexts()
    }
    
    // MARK: Action methods
    
    @IBAction func didSelectCamera() {
        
        delegate.didSelectCamera()
    }
    
    @IBAction func didSelectFacebook() {
        
        delegate.didSelectFacebook()
    }
    
    @IBAction func didSelectTwitter() {
        
        delegate.didSelectTwitter()
    }
    
    @IBAction func didSelectRecords() {
     
        delegate.didSelectRecords()
    }
    
    // MARK: Private methods

    fileprivate func localizeTexts() {
        
        self.title.text = NSLocalizedString("MAIN_SELECT_SOURCE", comment: "Title for selecting source")
        self.camera.setTitle(NSLocalizedString("MAIN_CAMERA", comment: "Camera option"), for: .normal)
        self.showRecords.setTitle(NSLocalizedString("MAIN_RECORDS", comment: "Button to show records"), for: .normal)
    }
}
