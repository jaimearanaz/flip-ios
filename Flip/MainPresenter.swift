//
//  MainPresenter.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

class MainPresenter: FLPBasePresenter, MainPresenterDelegate {
    
    // trick-non-optional var to be able to set delegate from Objective-C classes
    var controllerDelegate: AnyObject = "" as AnyObject  {
        didSet {
            if let delegate = controllerDelegate as? MainViewControllerDelegate {
                self.realControllerDelegate = delegate
            }
        }
    }
    
    // real delegate to use inside of the class
    var realControllerDelegate: MainViewControllerDelegate!
    
    // overrides property in Objective-c class DWPBasePresenter
    override var viewController: UIViewController {
        get {
            return self.realControllerDelegate.viewController
        }
    }
    
    // MARK: - MainPresenterDelegate methods
        
    func didSelectOptions(source: GameSource, size: GameSize) {
        
        downloadPictures(fromSource: source, size: size)
    }
    
    // MARK: - Private methods
    
    fileprivate func downloadPictures(fromSource source: GameSource, size: GameSize) {
        
        realControllerDelegate.startLoadingState()
    }
}
