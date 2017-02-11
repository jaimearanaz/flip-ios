//
//  SourceView.swift
//  Flip
//
//  Created by Jaime on 11/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

@objc class SourceView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var camera: UIButton!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var showRecords: UIButton!
    
    var delegate: SourceViewDelegate!
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupView()
        addSubview(view)
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
    
    private func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    private func setupView() {
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
    }
}
