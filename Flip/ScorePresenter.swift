//
//  ScorePresenter.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class ScorePresenter: FLPBasePresenter, ScorePresenterDelegate {
    
    // trick-non-optional var to be able to set delegate from Objective-C classes
    var controllerDelegate: AnyObject = "" as AnyObject  {
        didSet {
            if let delegate = controllerDelegate as? ScoreViewControllerDelegate {
                self.realControllerDelegate = delegate
            }
        }
    }
    
    // real delegate to use inside of the class
    var realControllerDelegate: ScoreViewControllerDelegate!
    
    // TODO: use dependency injection
    fileprivate let dataSouce = DataSource()
    
    // overrides property in Objective-c class FLPBasePresenter
    override var viewController: UIViewController {
        get {
            return self.realControllerDelegate.viewController
        }
    }
    
    // MARK: - Public methods
    
    func showScore(_ score: Score, isNewRecord: Bool) {
        
        realControllerDelegate.showScore(score, isNewRecord: isNewRecord)
    }
    
    // MARK: - ScorePresenterDelegate methods
    
    func didSelectTryAgain() {
        
        // TODO: implement
    }
    
    func didSelectMain() {
     
        // TODO: implement
    }
}
