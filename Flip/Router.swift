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
    
    func presentGrid(withImages images: [UIImage], andSize size: GameSize) {

        let presenter = presenterInstances.gridPresenter
        let viewController = presenterInstances.gridPresenter.viewController
        
        presenter.showGrid(withImages: images, andSize: size)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentScore(_ score: Score) {
        
        let presenter = presenterInstances.scorePresenter
        let viewController = presenterInstances.scorePresenter.viewController
        
        presenter.showScore(score)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func dismissCurrentViewController() {
        
        navigationController.popViewController(animated: true)
    }
}
