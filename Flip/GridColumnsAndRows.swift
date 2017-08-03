//
//  GridRowsAndColumns.swift
//  Flip
//
//  Created by Jaime on 27/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class GridColumnsAndRows {
    
    static fileprivate let iPhone4and4_7Small: (columns: Int, rows: Int) = (3, 4)
    static fileprivate let iPhone4and4_7Medium: (columns: Int, rows: Int) = (4, 5)
    static fileprivate let iPhone4and4_7Big: (columns: Int, rows: Int) = (4, 6)
    static fileprivate let iPhone5_5AndiPadSmall: (columns: Int, rows: Int) = (3, 4)
    static fileprivate let iPhone5_5AndiPadMedium: (columns: Int, rows: Int) = (3, 6)
    static fileprivate let iPhone5_5AndiPadBig: (columns: Int, rows: Int) = (4, 6)
    
    // MARK: Public methods
    
    static func getColumnsAndRows(forGameSize gameSize: GameSize) -> (columns: Int, rows: Int) {
        
        let isSmallScreen = DWPDevice.isiPhone4Inches() || DWPDevice.isiPhone4_7Inches()
        
        if (isSmallScreen) {
            return getColumnsAndRowsForSmallScreen(withGameSize: gameSize)
        } else {
            return getColumnsAndRowsForBiggerScreen(withGameSize: gameSize)
        }
    }
    
    // MARK: - Private methods
    
    static fileprivate func getColumnsAndRowsForSmallScreen(withGameSize gameSize: GameSize) -> (columns: Int, rows: Int) {
        
        switch gameSize {
        case .small:
            return iPhone4and4_7Small
        case .medium:
            return iPhone4and4_7Medium
        case .big,
             .unkown:
            return iPhone4and4_7Big
        }
    }
    
    static fileprivate func getColumnsAndRowsForBiggerScreen(withGameSize gameSize: GameSize) -> (columns: Int, rows: Int) {
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            
            switch gameSize {
            case .small:
                return (iPhone5_5AndiPadSmall.rows, iPhone5_5AndiPadSmall.columns)
            case .medium:
                return (iPhone5_5AndiPadMedium.rows, iPhone5_5AndiPadMedium.columns)
            case .big,
                 .unkown:
                return (iPhone5_5AndiPadBig.rows, iPhone5_5AndiPadBig.columns)
            }
            
        default:
            
            switch gameSize {
            case .small:
                return iPhone5_5AndiPadSmall
            case .medium:
                return iPhone5_5AndiPadMedium
            case .big,
                 .unkown:
                return iPhone5_5AndiPadBig
            }
        }
    }
}
