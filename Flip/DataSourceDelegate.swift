//
//  DataSourceDelegate.swift
//  Flip
//
//  Created by Jaime on 26/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation

enum PhotosErrorType: Int {
    case notEnough
    case cancelled
    case downloading
    case unknown
}

protocol DataSourceDelegate {
    
    func getRecords(completion: ((_ records: Records) -> Void))
    
    func setRecords(_ records: Records, completion: (() -> Void))
    
    func getTwitterPhotos(forSize size: GameSize,
                          success: @escaping ((_ photos: [String]) -> Void),
                          failure: @escaping ((_ error: PhotosErrorType) -> Void))
    
    func getFacebookPhotos(forSize size: GameSize,
                           inViewController viewController: AnyObject,
                           success: @escaping ((_ photos: [String]) -> Void),
                           failure: @escaping ((_ error: PhotosErrorType) -> Void))
    
    func getCameraPhotos(forSize size: GameSize,
                         success: @escaping ((_ photos: [String]) -> Void),
                         failure: @escaping ((_ error: PhotosErrorType) -> Void))
}
