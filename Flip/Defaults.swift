//
//  Defaults.swift
//  BaseProject
//
//  Created by Jaime Aranaz on 08/03/2017.
//  Copyright © 2017 Jaime Aranaz. All rights reserved.
//

import Foundation

class Defaults: DefaultsDelegate {
    
    fileprivate let recordsKey = "recordsKey"
    
    // MARK: DefaultsDelegate methods
    
    func getRecords(completion: ((_ records: Records) -> Void)) {
        
        let recordsArray = UserDefaults.standard.array(forKey: recordsKey)
        
        let records = Records()
        if (recordsArray?.count == 3) {
            records.big = (recordsArray![0] as? TimeInterval) ?? 0
            records.medium = (recordsArray![1] as? TimeInterval) ?? 0
            records.small = (recordsArray![2] as? TimeInterval) ?? 0
        }

        completion(records)
    }
    
    func setRecords(_ records: Records, completion: (() -> Void)) {
        
        let recordsArray = [records.big, records.medium, records.small]
        UserDefaults.standard.set(recordsArray, forKey: recordsKey)
        
        completion()
    }
}
