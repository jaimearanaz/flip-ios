//
//  RecordsView.swift
//  Flip
//
//  Created by Jaime on 11/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class RecordsView: UIViewFromNib {
 
    @IBOutlet var title: UILabel!
    @IBOutlet var smallLabel: UILabel!
    @IBOutlet var smallTime: UILabel!
    @IBOutlet var mediumLabel: UILabel!
    @IBOutlet var mediumTime: UILabel!
    @IBOutlet var bigLabel: UILabel!
    @IBOutlet var bigTime: UILabel!
    @IBOutlet var startNewGame: UIButton!
    
    var delegate: RecordsViewDelegate!
    
    // MARK: - Lifecycle methods
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        localizeTexts()
    }
    
    // MARK: - Action methods
    
    @IBAction func didSelectStartGame() {
     
        delegate.didSelectStartGame()
    }
    
    // MARK: - Private methods
    
    fileprivate func localizeTexts() {
        
        title.text =  NSLocalizedString("MAIN_RECORDS_TITLE", comment: "Title for records screen")
        
        smallLabel.text =  NSLocalizedString("MAIN_SMALL", comment: "Small record title")
        smallTime.text = NSLocalizedString("MAIN_RECORDS_NONE", comment: "Time when there is no value")
        
        mediumLabel.text = NSLocalizedString("MAIN_MEDIUM", comment: "Medium record title")
        mediumTime.text = NSLocalizedString("MAIN_RECORDS_NONE", comment: "Time when there is no value")
        
        bigLabel.text =  NSLocalizedString("MAIN_BIG", comment: "Big record title")
        bigTime.text = NSLocalizedString("MAIN_RECORDS_NONE", comment: "Time when there is no value")
        
        let startTitle = NSLocalizedString("MAIN_START", comment: "Button to start a new game")
        startNewGame.setTitle(startTitle, for: .normal)
    }
}
