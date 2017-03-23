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
    
    func showGrid(withImages images: [UIImage], andSize size: GameSize) {
        
        let gridCells = createGridCells(withImages: images)
        realControllerDelegate.showItems(gridCells, withSize: size)
    }
    
    // MARK: - GridPresenterDelegate methods
    
    func didSelectExit() {
        
        Router.sharedInstance.dismissCurrentViewController()
    }
    
    func gameFinished(withTime time: TimeInterval, numberOfErrors: Int) {

        let dateFormmatter = DateFormatter()
        dateFormmatter.setLocalizedDateFormatFromTemplate("mm:ss:SSS")
        let timeString = dateFormmatter.string(from: Date(timeIntervalSince1970: time))
        
        print("time \(timeString), errors \(numberOfErrors)")
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
}
