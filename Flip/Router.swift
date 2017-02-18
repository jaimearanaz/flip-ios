//
//  Router.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

@objc class Router: NSObject {
    
    static let sharedInstance = Router()
    
    var presenterInstances = PresenterInstances()
    
    lazy var navigationController: UINavigationController = {
        
        let rootViewController = Router.sharedInstance.presenterInstances.mainPresenter.viewController
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.isNavigationBarHidden = true
        
        return navigationController
    }()
    
    func presentGridWithImages(images: [UIImage]) {

        navigationController.pushViewController(presenterInstances.gridPresenter.viewController, animated: true)
    }
    
    func dismissCurrentViewController() {
        
        navigationController.popViewController(animated: true)
    }
}
