//
//  ScorePresenter.swift
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class ScorePresenter: FLPBasePresenter, ScorePresenterDelegate {

    fileprivate var dataSource: DataSourceDelegate!
    fileprivate var controllerDelegate: ScoreViewControllerDelegate!
    fileprivate var router: RouterDelegate!
    fileprivate var images = [UIImage]()
    fileprivate var gameSize: GameSize = .small
    
    // MARK: - Public methods
    
    func setupPresenter(controllerDelegate: ScoreViewControllerDelegate,
                        dataSource: DataSourceDelegate,
                        router: RouterDelegate) {
        
        self.controllerDelegate = controllerDelegate
        self.dataSource = dataSource
        self.router = router
    }
    
    func viewController() -> UIViewController? {
        
        return controllerDelegate as? UIViewController
    }
    
    func showScore(_ score: Score, isNewRecord: Bool) {
        
        controllerDelegate.showScore(score, isNewRecord: isNewRecord)
    }
    
    // MARK: - ScorePresenterDelegate methods
    
    func didSelectTryAgain() {
        
        Router.sharedInstance.presentLastGrid()
    }
    
    func didSelectMain() {
     
        Router.sharedInstance.presenMain()
    }
}
