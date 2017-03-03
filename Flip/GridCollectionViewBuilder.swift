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
    
    fileprivate let cellRatio: CGFloat = (100 / 90)
    fileprivate let minMargin: CGFloat = 5
    
    fileprivate var gridCellsModels = [GridCellStatus]()
    fileprivate var collectionView: UICollectionView!
    fileprivate var cellSize = CGSize(width: 0, height: 0)
    fileprivate var sideMargin: CGFloat = 0
    fileprivate var edgeMargin: CGFloat = 0
    fileprivate var columnsAndRows: (columns: Int, rows: Int)
    fileprivate var delegate: GridCollectionViewBuilderDelegate?
    
    // MARK: - Lifecycle methods
    
    init(collectionView: UICollectionView, size: GameSize, models: [GridCellStatus], delegate: GridCollectionViewBuilderDelegate) {
        
        self.collectionView = collectionView
        let nib = UINib.init(nibName: kFLPCollectionViewCellIdentifier, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: kFLPCollectionViewCellIdentifier)
        
        columnsAndRows = GridColumnsAndRows.getColumnsAndRows(forGameSize: size)
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
        
        return UIEdgeInsets(top: edgeMargin, left: sideMargin, bottom: edgeMargin, right: sideMargin)
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
        
        let columns = columnsAndRows.columns
        let rows = columnsAndRows.rows
        
        let availableHeight = collectionView.frame.height - (minMargin * CGFloat(rows + 1))
        cellHeight = availableHeight / CGFloat(rows)
        cellWidth = cellHeight / cellRatio
        
        let offset = collectionView.frame.width - (cellWidth * CGFloat(columns)) - (minMargin * CGFloat(columns + 1))
        
        if (offset < 0) {
            
            let offsetPerCell = abs(offset) / CGFloat(columns)
            cellWidth -= (offsetPerCell)
            cellHeight = cellWidth * cellRatio
        }
        
        sideMargin = (collectionView.frame.width - (cellWidth * CGFloat(columns))) / CGFloat(columns + 1)
        edgeMargin = (collectionView.frame.height - (cellHeight * CGFloat(columns)) - (minMargin * 2)) / CGFloat(rows + 1)
        
        return CGSize(width: cellWidth, height: cellHeight)
        
        // alto = (alto collection view - margen mínimo * (filas + 1)) / filas
        // ancho = alto / ratio
        
        // sobrante = ancho collection view - ((ancho * columnas) + (margen mínimo * (columnas + 1))
        // si (sobrante < 0)
        //      reduccion total = abs(sobrante)
        //      reducción celda = recucción total / columnas
        //      ancho = ancho - reducción celda
        //      alto = ancho * ratio
        
        // return alto y ancho
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
