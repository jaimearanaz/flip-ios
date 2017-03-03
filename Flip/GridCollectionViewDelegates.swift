//
//  CollectionViewDelegates.swift
//  Flip
//
//  Created by Jaime on 26/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

@objc class GridCollectionViewDelegates: NSObject, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    let cellRatio = (100 / 90)
    let minMargin: CGFloat = 5
    
    var gridCellsModels = [GridCellStatus]()
    var collectionView: UICollectionView!
    var cellSize = CGSize(width: 0, height: 0)
    var rowsAndColumns: (columns: Int, rows: Int)
    
    // MARK: - Lifecycle methods
    
    init(collectionView: UICollectionView, size: GameSize, models: [GridCellStatus]) {
        
        self.collectionView = collectionView
        rowsAndColumns = GridRowsAndColumns.getColumnsAndRows(forGameSize: size)
        gridCellsModels = models
    }
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.collectionView == nil) {
            self.collectionView = collectionView
        }
        
        return gridCellsModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return UICollectionViewCell()
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
            
        }
        
        return cellSize;
    }
}
