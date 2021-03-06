//
//  PresenterInstances.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class PresenterInstances {
    
    lazy var mainPresenter: MainPresenter = {
        
        let presenter = MainPresenter()
        let viewController = FLPMainViewController(nibName: "FLPMainViewController", bundle: nil)

        presenter.setupPresenter(controllerDelegate: viewController,
                                 dataSource: DataSource(),
                                 router: Router.sharedInstance)
        viewController.setupViewController(presenter)
        
        return presenter
    }()
    
    lazy var gridPresenter: GridPresenter = {
        
        let presenter = GridPresenter()
        let viewController = FLPGridViewController(nibName: "FLPGridViewController", bundle: nil)

        presenter.setupPresenter(controllerDelegate: viewController,
                                 dataSource: DataSource(),
                                 router: Router.sharedInstance)
        viewController.setupViewController(presenter)
        
        return presenter
    }()
    
    lazy var scorePresenter: ScorePresenter = {
        
        let presenter = ScorePresenter()
        let viewController = FLPScoreViewController(nibName: "FLPScoreViewController", bundle: nil)
        
        presenter.setupPresenter(controllerDelegate: viewController,
                                 dataSource: DataSource(),
                                 router: Router.sharedInstance)
        viewController.setupViewController(presenter)
        
        return presenter
    }()
}
