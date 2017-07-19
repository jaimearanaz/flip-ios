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
                   success: @escaping ((_ photos: [UIImage]) -> Void),
                   failure: @escaping ((_ error: CameraErrorType) -> Void)) {
        
        checkPhotoLibraryPermission(granted: {
            
            let result = self.getResultFromCameraRoll()
            let areEnough = (result.count >= numOfPhotos)
            
            if (areEnough) {
                self.getImagesFromResult(result, success: { (images) in
                    success(images[randomPick: numOfPhotos])
                }, failure: {
                    failure(.unknown)
                })
            } else {
                failure(.notEnough)
            }
            
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
    
    fileprivate func getResultFromCameraRoll() -> PHFetchResult<PHAsset> {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        let result = PHAsset.fetchAssets(with: .image, options: nil)
        
        return result
    }
    
    fileprivate func getImagesFromResult(_ result: PHFetchResult<PHAsset>,
                                         success: @escaping ((_ photos: [UIImage]) -> Void),
                                         failure: @escaping (() -> Void)) {
        
        var images = [UIImage]()
        result.enumerateObjects({ asset, index, stop in
            
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
          
            asset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                
                if let content = contentEditingInput, let displayImage = content.displaySizeImage {
                    images.append(displayImage)
                    if (images.count == result.count) {
                        success(images)
                    }
                } else {
                    stop.pointee = true
                    failure()
                }
            })
        })
    }
}
