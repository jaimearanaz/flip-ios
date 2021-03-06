//
//  RouterDelegate.swift
//  Flip
//
//  Created by Jaime on 30/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

protocol RouterDelegate {
    
    func presenMain()

    func presentGrid(withImageUrls imageUrls: [String], andSize size: GameSize, completion: @escaping (()->Void))
    
    func presentGrid(withImages images: [UIImage], andSize size: GameSize, completion: @escaping (()->Void))
    
    func presentLastGrid()
    
    func presentScore(_ score: Score, isNewRecord: Bool)
    
    func dismissCurrentViewController()
}
