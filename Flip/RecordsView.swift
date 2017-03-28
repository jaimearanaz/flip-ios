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
    
    // MARK: - Public methods
    
    func showRecords(_ records: Records) {
        
        let emptyRecord = NSLocalizedString("MAIN_RECORDS_NONE", comment: "Time when there is no value")
        
        smallTime.text = (records.small == 0) ? emptyRecord : readableTime(records.small)
        mediumTime.text = (records.medium == 0) ? emptyRecord : readableTime(records.medium)
        bigTime.text = (records.big == 0) ? emptyRecord : readableTime(records.big)
    }
    
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
        mediumLabel.text = NSLocalizedString("MAIN_MEDIUM", comment: "Medium record title")
        bigLabel.text =  NSLocalizedString("MAIN_BIG", comment: "Big record title")

        let startTitle = NSLocalizedString("MAIN_START", comment: "Button to start a new game")
        startNewGame.setTitle(startTitle, for: .normal)
    }
    
    fileprivate func readableTime(_ time: TimeInterval) -> String {
        
        let dateFormmatter = DateFormatter()
        dateFormmatter.setLocalizedDateFormatFromTemplate("mm:ss:SSS")
        let timeString = dateFormmatter.string(from: Date(timeIntervalSince1970: time))
        
        return timeString
    }
}
