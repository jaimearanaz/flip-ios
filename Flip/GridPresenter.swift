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
    
    // overrides property in Objective-c class FLPBasePresenter
    override var viewController: UIViewController {
        get {
            return self.realControllerDelegate.viewController
        }
    }
    
    var gameSize: GameSize = .small
    
    // MARK: - Public methods
    
    func showGrid(withImages images: [UIImage], andSize size: GameSize) {
        
        gameSize = size
        let gridCells = createGridCells(withImages: images)
        realControllerDelegate.showItems(gridCells, withSize: size)
    }
    
    // MARK: - GridPresenterDelegate methods
    
    func didSelectExit() {
        
        Router.sharedInstance.dismissCurrentViewController()
    }
    
    func gameFinished(withTime time: TimeInterval, numberOfErrors: Int) {

        let score = Score()
        score.time = time
        score.errors = numberOfErrors
        score.penalization = Double(penalizationInSeconds(forErrors: numberOfErrors, withGameSize: gameSize))
        score.finalTime = time + Double(score.penalization)
        
        Router.sharedInstance.presentScore(score)
    }
    
    // MARK: - Private methods
    
    fileprivate func createGridCells(withImages images: [UIImage]) -> [GridCell] {
    
        var mirroredImages = images
        mirroredImages.append(contentsOf: images)
        mirroredImages.shuffle()
        
        var cellsForGrid = [GridCell]()
        var currentIndex = 0
        for image in mirroredImages {
            
            var pairIndex = 0;
            for pairImage in mirroredImages {
                if (pairImage == image) && (currentIndex != pairIndex) {
                    break;
                }
                pairIndex += 1
            }
            
            let gridCell = GridCell()
            gridCell.image = image
            gridCell.equalIndex = pairIndex;
            cellsForGrid.append(gridCell)
            currentIndex += 1
        }
        
        return cellsForGrid
    }
    
    fileprivate func penalizationInSeconds(forErrors errors: Int, withGameSize gameSize: GameSize) -> Int {
        
        var penalization = 0
        
        switch gameSize {
        case .small:
            penalization = errors * GamePenalization.small.rawValue
            break
        case .medium:
            penalization = errors * GamePenalization.medium.rawValue
            break
        case .big:
            penalization = errors * GamePenalization.big.rawValue
            break
        }
        
        return penalization
    }
}
