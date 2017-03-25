//
//  ScoreResultView.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

class ScoreResultView: UIViewFromNib {

    @IBOutlet var titleView: UILabel!
    @IBOutlet var valueView: UILabel!
    
    // MARK: - Public methods
    
    func setupView(withTitle title: String) {
        
        titleView.text = title
    }
    
    func setupView(withValue value: String) {
        
        valueView.text = value
    }
}
