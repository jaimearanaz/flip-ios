//
//  GridRowsAndColumns.swift
//  Flip
//
//  Created by Jaime on 27/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class GridRowsAndColumns {
    
    static fileprivate let iPhone4and4_7Small: (columns: Int, rows: Int) = (3, 4)
    static fileprivate let iPhone4and4_7Medium: (columns: Int, rows: Int) = (4, 5)
    static fileprivate let iPhone4and4_7Big: (columns: Int, rows: Int) = (4, 6)
    static fileprivate let iPhone5_5AndiPadSmall: (columns: Int, rows: Int) = (3, 4)
    static fileprivate let iPhone5_5AndiPadMedium: (columns: Int, rows: Int) = (3, 6)
    static fileprivate let iPhone5_5AndiPadBig: (columns: Int, rows: Int) = (4, 6)
    
    static func getColumnsAndRows(forGameSize gameSize: GameSize) -> (columns: Int, rows: Int) {
        
        let isSmallScreen = DWPDevice.isiPhone4Inches() || DWPDevice.isiPhone4_7Inches()
        
        if (isSmallScreen) {
            
            switch gameSize {
            case .small:
                return iPhone4and4_7Small
            case .medium:
                return iPhone4and4_7Medium
            case .big:
                return iPhone4and4_7Big
            }
            
        } else {
            
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                
                switch gameSize {
                case .small:
                    return iPhone5_5AndiPadSmall
                case .medium:
                    return iPhone5_5AndiPadMedium
                case .big:
                    return iPhone5_5AndiPadBig
                }

            default:
                
                switch gameSize {
                case .small:
                    return (iPhone4and4_7Small.rows, iPhone4and4_7Small.columns)
                case .medium:
                    return (iPhone5_5AndiPadMedium.rows, iPhone5_5AndiPadMedium.columns)
                case .big:
                    return (iPhone5_5AndiPadBig.rows, iPhone5_5AndiPadBig.columns)
                }

            }
        }
    }
}
