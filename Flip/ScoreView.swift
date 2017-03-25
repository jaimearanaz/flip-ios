//
//  ScoreView.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

@objc class ScoreView: UIViewFromNib {
    
    @IBOutlet var titleView: UILabel!
    @IBOutlet var timeView: ScoreResultView!
    @IBOutlet var errorsView: ScoreResultView!
    @IBOutlet var penalizationView: ScoreResultView!
    @IBOutlet var finalTimeView: ScoreResultView!

    // MARK: - Lifecycle methods
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        localizeTexts()
    }
    
    // MARK: Public methods
    
    func showScore(_ score: Score) {
        
        // TODO: implement
    }
    
    // MARK: Private methods
    
    fileprivate func localizeTexts() {
        
        // TODO: implement
    }
}
