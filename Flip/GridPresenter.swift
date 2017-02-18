//
//  GridPresenter.swift
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class GridPresenter: FLPBasePresenter, GridPresenterDelegate {
    
    // trick-non-optional var to be able to set delegate from Objective-C classes
    var controllerDelegate: AnyObject = "" as AnyObject  {
        didSet {
            if let delegate = controllerDelegate as? NewGridViewControllerDelegate {
                self.realControllerDelegate = delegate
            }
        }
    }
    
    // real delegate to use inside of the class
    var realControllerDelegate: NewGridViewControllerDelegate!
    
    // overrides property in Objective-c class DWPBasePresenter
    override var viewController: UIViewController {
        get {
            return self.realControllerDelegate.viewController
        }
    }
    
    // MARK: - Public methods
    
    func showGridWithPictures(pictures: [UIImage]) {
        
        realControllerDelegate.showPictures(pictures: pictures)
    }
    
    // MARK: - GridPresenterDelegate methods
    
    func didSelectExit() {
        
        Router.sharedInstance.dismissCurrentViewController()
    }
    
    func didSelectFinish(time: TimeInterval, errors: Int) {
        
        // TODO: implement
    }
    
}
