//
//  TitleView.swift
//  Flip
//
//  Created by Jaime on 11/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class TitleView: UIViewFromNib {

    @IBOutlet var lettersView: UIStackView!
    
    var timer: Timer?
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Public methods
    
    func startAnimation() {
        timer = Timer.scheduledTimer(timeInterval: 3.0,
                                     target: self,
                                     selector: #selector(animateRandomLetter),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopAnimation() {
        
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // MARK: Private methods
    
    @objc fileprivate func animateRandomLetter() {
        
        let random = (arc4random() % 4)
        var index: UInt32 = 0
        var letterView: FLPTitleLetterView!
        for oneSubview in lettersView.subviews {
            if (index == random) {
                letterView = oneSubview as! FLPTitleLetterView
                break
            } else {
                index += 1
            }
        }

        letterView.perform(#selector(FLPTitleLetterView.flipAnimated(_:)), with: NSNumber(booleanLiteral: true))
    }
}
