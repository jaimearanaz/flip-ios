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
    case unknown
}

class CameraPhotos {
    
    // MARK: - Public methods
    
    func getPhotos(_ numOfPhotos: Int,
                   success: @escaping ((_ photos: [String]) -> Void),
                   failure: @escaping ((_ error: CameraErrorType) -> Void)) {
        

        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        let result = PHAsset.fetchAssets(with: .image, options: nil)

        var manager = PHImageManager.default()
    }
    
    // MARK: - Private methods
}
