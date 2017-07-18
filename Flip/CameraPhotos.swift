//
//  CameraPhotos.swift
//  Flip
//
//  Created by Jaime on 18/07/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import Photos

enum CameraErrorType {
    
    case notEnough
    case notGranted
    case unknown
}

class CameraPhotos {
    
    // MARK: - Public methods
    
    func getPhotos(_ numOfPhotos: Int,
                   success: @escaping ((_ photos: [String]) -> Void),
                   failure: @escaping ((_ error: CameraErrorType) -> Void)) {
        
        checkPhotoLibraryPermission(granted: {
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = .exact
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isSynchronous = true
            let result = PHAsset.fetchAssets(with: .image, options: nil)
            
            var manager = PHImageManager.default()

            result.enumerateObjects({ asset, index, stop in
                
                if let asset = asset as? PHAsset {
                    let date = asset.creationDate
                    print("\(date)")
                }
                
            })
            
        }, notGranted: {
            
            failure(.notGranted)
        })
    }
    
    // MARK: - Private methods
    
    fileprivate func checkPhotoLibraryPermission(granted: @escaping (()->Void), notGranted: @escaping (()->Void)) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            granted()
            break
        case .denied, .restricted :
            notGranted()
            break
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization() { status in
                self.checkPhotoLibraryPermission(granted: granted, notGranted: notGranted)
            }
        }
    }
}
