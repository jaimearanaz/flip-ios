//
//  CollectionViewDelegates.swift
//  Flip
//
//  Created by Jaime on 26/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class GridCollectionViewBuilder: NSObject, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellRatio = (100 / 90)
    fileprivate let minMargin: CGFloat = 5
    
    fileprivate var gridCellsModels = [GridCellStatus]()
    fileprivate var collectionView: UICollectionView!
    fileprivate var cellSize = CGSize(width: 0, height: 0)
    fileprivate var rowsAndColumns: (columns: Int, rows: Int)
    fileprivate var delegate: GridCollectionViewBuilderDelegate?
    
    // MARK: - Lifecycle methods
    
    init(collectionView: UICollectionView, size: GameSize, models: [GridCellStatus], delegate: GridCollectionViewBuilderDelegate) {
        
        self.collectionView = collectionView
        let nib = UINib.init(nibName: kFLPCollectionViewCellIdentifier, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: kFLPCollectionViewCellIdentifier)
        
        rowsAndColumns = GridColumnsAndRows.getColumnsAndRows(forGameSize: size)
        gridCellsModels = models
        self.delegate = delegate
    }
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didSelectCell(withIndexPath: indexPath)
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return gridCellsModels.count
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
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Private methods
    
    fileprivate func getCellSize() -> CGSize {
        
        let firstUse = cellSize.equalTo(CGSize(width: 0, height: 0))
        if (firstUse) {
            cellSize = CGSize(width: 90, height: 100)
        }
        
        return cellSize;
    }
    
    fileprivate func gridCellForIndexPath(_ indexPath: IndexPath) -> FLPCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFLPCollectionViewCellIdentifier, for: indexPath) as! FLPCollectionViewCell
        
        let cellModel = gridCellsModels[indexPath.item]
        cell.setupCell(withModel: cellModel.gridCell, andNumber: indexPath.item + 1)
        cell.flipToUserImage(withAnimation: NSNumber.init(booleanLiteral: false), onCompletion: nil)
        
        return cell
    }
    
    fileprivate func callDelegateIfLastIndexPath(_ indexPath: IndexPath) {
        
        let lastCell = (indexPath.item == (gridCellsModels.count - 1))
        if (lastCell) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.collectionViewIsBuilt()
            }
        }
    }
}
