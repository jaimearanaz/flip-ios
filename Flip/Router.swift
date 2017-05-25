//
//  Router.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

import UINavigationControllerWithCompletionBlock

@objc class Router: NSObject, RouterDelegate {
    
    static let sharedInstance = Router()
    
    var presenterInstances = PresenterInstances()
    
    lazy var navigationController: UINavigationController = {
        
        let mainPresenter = Router.sharedInstance.presenterInstances.mainPresenter
        let rootViewController = mainPresenter.viewController()
        let navigationController = UINavigationController(rootViewController: rootViewController!)
        navigationController.isNavigationBarHidden = true
        
        return navigationController
    }()
    
    // MARK: - RouterDelegate methods
    
    func presenMain() {
        
        let mainPresenter = Router.sharedInstance.presenterInstances.mainPresenter
        navigationController.popToRootViewController(animated: true) { 
            mainPresenter.showRecords()
        }
    }
    
    func presentGrid(withImages images: [String], andSize size: GameSize, completion: @escaping (()->Void)) {

        let presenter = presenterInstances.gridPresenter
        let viewController = presenterInstances.gridPresenter.viewController()
        presenter.showGrid(withImages: images, andSize: size)
        
        navigationController.pushViewController(viewController, animated: true) {
            completion()
        }
    }
    
    func presentLastGrid() {
        
        let presenter = presenterInstances.gridPresenter
        presenter.repeatLastGrid()
        
        navigationController.popViewController(animated: true)
    }
    
    func presentScore(_ score: Score, isNewRecord: Bool) {
        
        let presenter = presenterInstances.scorePresenter
        let viewController = presenterInstances.scorePresenter.viewController()
        
        navigationController.pushViewController(viewController, animated: true) {
            presenter.showScore(score, isNewRecord: isNewRecord)
        }
    }
    
    func dismissCurrentViewController() {
        
        navigationController.popViewController(animated: true)
    }
}
