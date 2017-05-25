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
    
    func getTwitterPhotos(forSize size: GameSize,
                          success: @escaping ((_ photos: [String]) -> Void),
                          failure: @escaping ((_ error: PhotosErrorType) -> Void)) {
        
        let numberOfPhotos = (size.rawValue / 2)
        twitterPhotos.getPhotos(numberOfPhotos, success: { (pics) in
            
            let photos = pics as! [String]
            success(photos)
            
        }, failure: { (error) in
            
            let photosError = self.photosError(fromTwitterError: error)
            failure(photosError)
        })
    }
    
    // MARK: - Private methods
    
    fileprivate func photosError(fromTwitterError twitterError: TwitterErrorType) -> PhotosErrorType {
        
        var error: PhotosErrorType!
        
        switch twitterError {
        case TwitterErrorNotEnough:
            error = .notEnough
            break
        case TwitterErrorCancelled:
            error = .cancelled
            break
        case TwitterErrorDownloading:
            error = .downloading
            break
        default:
            error = .unknown
            break
        }
        
        return error
    }
}
