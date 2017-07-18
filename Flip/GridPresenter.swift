//
//  GridPresenter.swift
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class GridPresenter: FLPBasePresenter, GridPresenterDelegate {
    
    fileprivate var dataSource: DataSourceDelegate!
    fileprivate var controllerDelegate: GridViewControllerDelegate!
    fileprivate var router: RouterDelegate!
    fileprivate var images = [String]()
    fileprivate var gameSize: GameSize = .small
    
    // MARK: - Public methods
    
    func setupPresenter(controllerDelegate: GridViewControllerDelegate,
                        dataSource: DataSourceDelegate,
                        router: RouterDelegate) {
        
        self.controllerDelegate = controllerDelegate
        self.dataSource = dataSource
        self.router = router
    }
    
    func viewController() -> UIViewController? {
        
        return controllerDelegate as? UIViewController
    }
    
    func showGrid(withImages images: [String], andSize size: GameSize) {
        
        self.images = images
        gameSize = size
        let gridCells = createGridCells(withImages: images)
        controllerDelegate.showItems(gridCells, withSize: size)
    }
    
    func repeatLastGrid() {
        
        let gridCells = createGridCells(withImages: images)
        controllerDelegate.showItems(gridCells, withSize: gameSize)
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
        
        isNewRecord(time: score.finalTime, gameSize: gameSize) { (isNewRecord, records) in
            
            if (isNewRecord) {
                saveTime(score.finalTime, inRecords: records, forGameSize: gameSize, completion: {
                    
                    Router.sharedInstance.presentScore(score, isNewRecord: isNewRecord)
                })
            } else {
                
                Router.sharedInstance.presentScore(score, isNewRecord: isNewRecord)
            }
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func createGridCells(withImages images: [String]) -> [GridCell] {
    
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
        default:
            break
        }
        
        return penalization
    }
    
    fileprivate func isNewRecord(time: TimeInterval, gameSize: GameSize, completion: ((_ isNewRecord: Bool, _ records: Records) -> Void)){
        
        self.dataSource.getRecords { (records) in
            
            var newRecord = false
            
            switch gameSize {
                
            case .big:
                newRecord = (records.big == 0) || (records.big > time)
                break
            case .medium:
                newRecord = (records.medium == 0) || (records.medium > time)
                break
            case .small:
                newRecord = (records.small == 0) || (records.small > time)
                break
            default:
                break
            }
            
            completion(newRecord, records)
        }
    }
    
    fileprivate func saveTime(_ time: TimeInterval, inRecords records: Records, forGameSize: GameSize, completion: (() -> Void)) {
        
        switch gameSize {
            
        case .big:
            records.big = time
            break
        case .medium:
            records.medium = time
            break
        case .small:
            records.small = time
            break
        default:
            break
        }
        
        self.dataSource.setRecords(records) {
            
            completion()
        }
    }
}
