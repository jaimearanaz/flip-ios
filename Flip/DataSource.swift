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
    fileprivate var facebookPhotos = FacebookPhotos()
    fileprivate var cameraPhotos = CameraPhotos()
    
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
        twitterPhotos.getPhotos(numberOfPhotos, success: { (images) in
            
            let photos = images as! [String]
            success(photos)
            
        }, failure: { (error) in
            
            let photosError = self.photosError(fromTwitterError: error)
            failure(photosError)
        })
    }
    
    func getFacebookPhotos(forSize size: GameSize,
                           inViewController viewController: AnyObject,
                           success: @escaping ((_ photos: [String]) -> Void),
                           failure: @escaping ((_ error: PhotosErrorType) -> Void)) {
        
        let numberOfPhotos = (size.rawValue / 2)
        facebookPhotos.getPhotos(numberOfPhotos,
                                 inViewController: viewController,
                                 success: { (images) in
                                    
                                    success(images)
                                    
        }, failure: { (error) in
            
            let photosError = self.photosError(fromFacebookError: error)
            failure(photosError)
        })
    }
    
    func getCameraPhotos(forSize size: GameSize,
                         success: @escaping ((_ photos: [UIImage]) -> Void),
                         failure: @escaping ((_ error: PhotosErrorType) -> Void)) {
        
        let numberOfPhotos = (size.rawValue / 2)
        cameraPhotos.getPhotos(numberOfPhotos,
                               success: { (images) in
                                
                                success(images)
                                
        }, failure: { (error) in
            
            let photosError = self.photosError(fromCameraError: error)
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
    
    fileprivate func photosError(fromFacebookError facebookError: FacebookErrorType) -> PhotosErrorType {
        
        var error: PhotosErrorType!
        
        switch facebookError {
        case .notEnough:
            error = .notEnough
            break
        case .cancelled:
            error = .cancelled
            break
        case .downloading:
            error = .downloading
            break
        default:
            error = .unknown
            break
        }
        
        return error
    }
    
    fileprivate func photosError(fromCameraError cameraError: CameraErrorType) -> PhotosErrorType {
        
        var error: PhotosErrorType!
        
        switch cameraError {
        case .notEnough:
            error = .notEnough
            break
        case .notGranted:
            error = .notGranted
            break
        default:
            error = .unknown
            break
        }
        
        return error
    }
}
