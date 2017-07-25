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
    @IBOutlet var centerConstraints: [NSLayoutConstraint]!
    
    var delegate: ScoreViewDelegate?
    
    fileprivate let animationDuration = 0.5
    fileprivate let delayDuration = 0.2
    fileprivate var trailingConstraints = [NSLayoutConstraint]()

    // MARK: - Lifecycle methods
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        localizeTexts()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        hideScore()
    }
    
    // MARK: Public methods
    
    func showScore(_ score: Score) {

        var time = readableTime(score.time, withMilliseconds: true)
        timeView.setupView(withValue: time)
        
        errorsView.setupView(withValue: String(score.errors))
        
        time = readableTime(score.penalization, withMilliseconds: false)
        penalizationView.setupView(withValue: time)
        
        time = readableTime(score.finalTime, withMilliseconds: true)
        finalTimeView.setupView(withValue: time)
        
        showResultsWithAnimation()
    }
    
    func hideScore() {
        
        removeCenterConstraints()
        addTrailingConstraints()
    }
    
    // MARK: Private methods
    
    fileprivate func localizeTexts() {
        
        titleView.text = NSLocalizedString("SCORE_TITLE", comment: "Title for score view")
        
        let timeViewTitle = NSLocalizedString("SCORE_TIME", comment: "Score time")
        timeView.setupView(withTitle: timeViewTitle)
        
        let errorsViewTitle = NSLocalizedString("SCORE_ERRORS", comment: "Score errors")
        errorsView.setupView(withTitle: errorsViewTitle)
        
        let penalizationViewTitle = NSLocalizedString("SCORE_PENALIZATION", comment: "Score penalization")
        penalizationView.setupView(withTitle: penalizationViewTitle)
        
        let finalTimeViewTitle = NSLocalizedString("SCORE_TIME_FINAL", comment: "Score final time")
        finalTimeView.setupView(withTitle: finalTimeViewTitle)
    }
    
    // MARK: - Private methods
    
    fileprivate func readableTime(_ time: TimeInterval, withMilliseconds: Bool) -> String {
        
        let dateFormmatter = DateFormatter()
        let template = withMilliseconds ? "mm:ss:SSS" : "mm:ss"
        dateFormmatter.setLocalizedDateFormatFromTemplate(template)
        let timeString = dateFormmatter.string(from: Date(timeIntervalSince1970: time))
        
        return timeString
    }
    
    fileprivate func showResultsWithAnimation() {

        for i in 1...centerConstraints.count {
         
            let index = i - 1
            trailingConstraints[index].isActive = false
            centerConstraints[index].isActive = true
            
            UIView.animate(withDuration: animationDuration,
                           delay: (delayDuration * Double(i)),
                           options: .curveEaseInOut,
                           animations: {
                            
                            self.view.layoutIfNeeded()
                            
            }, completion: { (completed) in
                
                self.delegate?.didFinishAnimation()
            })
        }
    }
    
    fileprivate func removeCenterConstraints() {
        
        _ = centerConstraints.map({ $0.isActive = false})
    }
    
    fileprivate func addTrailingConstraints() {
     
        let trailingSpace = -frame.size.width
        
        if (trailingConstraints.count == 0) {
            
            trailingConstraints.append(timeView.addTrailingSpaceToSuperviewConstraint(trailingSpace: trailingSpace))
            trailingConstraints.append(errorsView.addTrailingSpaceToSuperviewConstraint(trailingSpace: trailingSpace))
            trailingConstraints.append(penalizationView.addTrailingSpaceToSuperviewConstraint(trailingSpace: trailingSpace))
            trailingConstraints.append(finalTimeView.addTrailingSpaceToSuperviewConstraint(trailingSpace: trailingSpace))
            
        } else {
            
            _ = trailingConstraints.map({ $0.isActive = true})
        }
    }
}
