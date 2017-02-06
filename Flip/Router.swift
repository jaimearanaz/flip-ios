//
//  Router.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

class Router {
    
    static let sharedInstance = Router()
 
    lazy var mainPresenter: MainPresenter = {
        
        let presenter = MainPresenter()
        let viewController = FLPMainViewController(nibName: "FLPMainViewController", bundle: nil)
        presenter.controllerDelegate = viewController
        //viewController.presenterDelegate = presenter
        
        return presenter
    }()
}
