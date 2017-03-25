//
//  CollectionViewDelegates.swift
//  Flip
//
//  Created by Jaime on 26/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class GridCollectionViewBuilder: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellRatio: CGFloat = (100 / 90)
    fileprivate let minMargin: CGFloat = 5
    
    fileprivate var gridCellsModels = [GridCellStatus]()
    fileprivate var collectionView: UICollectionView!
    fileprivate var cellSize = CGSize(width: 0, height: 0)
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    fileprivate var columnsAndRows: (columns: Int, rows: Int)
    fileprivate var isStartingGame: Bool
    fileprivate var delegate: GridCollectionViewBuilderDelegate?
    fileprivate var needsExtraSection = false
    fileprivate var ordinalForItem = 1
    
    // MARK: - Lifecycle methods
    
    init(collectionView: UICollectionView,
         size: GameSize,
         models: [GridCellStatus],
         isStartingGame: Bool,
         delegate: GridCollectionViewBuilderDelegate) {
        
        self.collectionView = collectionView
        let nib = UINib.init(nibName: kFLPCollectionViewCellIdentifier, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: kFLPCollectionViewCellIdentifier)
        
        columnsAndRows = GridColumnsAndRows.getColumnsAndRows(forGameSize: size)
        gridCellsModels = models
        let hasOrphanItems = ((columnsAndRows.columns * columnsAndRows.rows) % gridCellsModels.count != 0)
        needsExtraSection = hasOrphanItems
        self.isStartingGame = isStartingGame
        self.delegate = delegate
    }
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didSelectCell(withIndexPath: indexPath)
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return (needsExtraSection) ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (needsExtraSection) {
            
            let orphanItems = (columnsAndRows.columns * columnsAndRows.rows) % gridCellsModels.count
            let fullItems = gridCellsModels.count - orphanItems
            return (section == 0) ? fullItems : orphanItems
            
        } else {
            
            return gridCellsModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = gridCellForIndexPath(indexPath)
        callDelegateIfLastIndexPath(indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        return getCellSize()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return minMargin
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return minMargin
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var insets = calculateInsets()
        
        if (needsExtraSection) {
            if (section == 0) {
                insets = UIEdgeInsetsMake(insets.top, insets.left, minMargin, insets.right)
            } else {
                insets = UIEdgeInsetsMake(minMargin, insets.left, insets.bottom, insets.right)
            }
        }
        
        return insets
    }
    
    // MARK: - Private methods
    
    fileprivate func getCellSize() -> CGSize {
        
        let firstUse = cellSize.equalTo(CGSize(width: 0, height: 0))
        if (firstUse) {
            cellSize = calculateCellSize()
        }
        
        return cellSize;
    }
    
    fileprivate func calculateCellSize() -> CGSize {
        
        var cellHeight: CGFloat = 0
        var cellWidth: CGFloat = 0
        let columns = CGFloat(columnsAndRows.columns)
        let rows = CGFloat(columnsAndRows.rows)
        let collectionWidth = collectionView.frame.width
        let collectionHeight = collectionView.frame.height
        
        let availableHeight = collectionHeight - (minMargin * CGFloat(rows + 1))
        cellHeight = availableHeight / CGFloat(rows)
        // TODO: ñapa, solve this!
        cellHeight *= CGFloat(0.90)
        cellWidth = cellHeight / cellRatio
        
        let horizontalOffset = collectionWidth - (cellWidth * CGFloat(columns)) - (minMargin * CGFloat(columns + 1))
        
        if (horizontalOffset < 0) {
            
            let offsetPerCell = abs(horizontalOffset) / CGFloat(columns)
            cellWidth -= (offsetPerCell)
            // TODO: ñapa, solve this!
            cellWidth *= CGFloat(0.90)
            cellHeight = cellWidth * cellRatio
        }

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    fileprivate func calculateInsets() -> UIEdgeInsets {

        let cellHeight = cellSize.height
        let cellWidth = cellSize.width
        let columns = CGFloat(columnsAndRows.columns)
        let rows = CGFloat(columnsAndRows.rows)
        let collectionWidth = collectionView.frame.width
        let collectionHeight = collectionView.frame.height
        
        let sideMargin = (collectionWidth - (cellWidth * columns) - (minMargin * (columns - 1))) / 2
        let edgeMargin = (collectionHeight - (cellHeight * rows) - (minMargin * (rows - 1))) / 2
        let insets = UIEdgeInsets(top: edgeMargin, left: sideMargin, bottom: edgeMargin, right: sideMargin)

        return insets
    }
    
    fileprivate func gridCellForIndexPath(_ indexPath: IndexPath) -> FLPCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFLPCollectionViewCellIdentifier, for: indexPath) as! FLPCollectionViewCell
        
        let cellModel = gridCellsModels[ordinalForItem - 1]
        cell.setupCell(withModel: cellModel.gridCell, andNumber: ordinalForItem)
        ordinalForItem += 1
        
        if (isStartingGame) {
            
            cell.flipToUserImage(withAnimation: NSNumber.init(booleanLiteral: false), onCompletion: nil)
            
        } else {
            
            if (cellModel.isFlipped) {
                cell.flipToUserImage(withAnimation: NSNumber.init(booleanLiteral: false), onCompletion: nil)
            } else {
                cell.flipToCover(withAnimation: NSNumber.init(booleanLiteral: false), onCompletion: nil)
            }
        }
        
        return cell
    }
    
    fileprivate func callDelegateIfLastIndexPath(_ indexPath: IndexPath) {
        
        let orphanItems = (columnsAndRows.columns * columnsAndRows.rows) % gridCellsModels.count
        let lastIndexPathForOneSection = ((indexPath.section == 0) && (indexPath.item == (gridCellsModels.count - 1)))
        let lastIndexPathForTwoSections = ((indexPath.section == 1) && (indexPath.item == (orphanItems - 1)))
        let lastCell = lastIndexPathForOneSection || lastIndexPathForTwoSections
        if (lastCell) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.collectionViewIsBuilt()
            }
        }
    }
}
