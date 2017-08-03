//
//  GridCollectionViewBuilderDelegate.swift
//  Flip
//
//  Created by Jaime Aranaz on 03/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GridCollectionControllerDelegate {
    
    func collectionViewIsBuilt()
    
    func didSelectCell(withIndexPath indexPath: IndexPath)
}
