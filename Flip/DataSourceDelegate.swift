//
//  DataSourceDelegate.swift
//  Flip
//
//  Created by Jaime on 26/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

protocol DataSourceDelegate {
    
    func getRecords(completion: ((_ records: Records) -> Void))
    
    func setRecords(_ records: Records, completion: (() -> Void))
}
