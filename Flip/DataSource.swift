//
//  DataSource.swift
//  Flip
//
//  Created by Jaime on 26/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

class DataSource: DataSourceDelegate {
    
    // TODO: use dependency injection
    fileprivate var defaults = Defaults()
    
    // MARK: - DataSourceDelegate methods
    
    func getRecords(completion: ((_ records: Records) -> Void)){
        
        self.defaults.getRecords(completion: completion)
    }
    
    func setRecords(_ records: Records, completion: (() -> Void)) {
        
        self.defaults.setRecords(records, completion: completion)
    }
}
