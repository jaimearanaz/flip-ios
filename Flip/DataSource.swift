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
    fileprivate var twitterPhotos = FLPTwitterPhotos()
    
    // MARK: - DataSourceDelegate methods
    
    func getRecords(completion: ((_ records: Records) -> Void)){
        
        self.defaults.getRecords(completion: completion)
    }
    
    func setRecords(_ records: Records, completion: (() -> Void)) {
        
        self.defaults.setRecords(records, completion: completion)
    }
    
    func getTwitterPhotos(forSize size: GameSize, success: @escaping ((_ photos: [String]) -> Void), failure:@escaping (() -> Void)) {

        twitterPhotos.getPhotos(size.rawValue, success: { (pics) in

            let photos = pics as! [String]
            success(photos)
            
        }, failure: { 
            failure()
        })
    }
}
