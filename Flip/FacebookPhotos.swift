//
//  FacebookPhotos.swift
//  Flip
//
//  Created by Jaime on 16/06/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import FBSDKLoginKit
import Foundation
import UIKit

enum FacebookErrorType {
    
    case notEnough
    case cancelled
    case downloading
    case notViewController
    case unknown
}

class FacebookPhotos {
    
    fileprivate var photosUrls = [String]()
    
    // MARK: - Public methods

    fileprivate let permissions = ["user_photos"]
    
    func getPhotos(_ numOfPhotos: Int,
                   inViewController viewController: AnyObject,
                   success: @escaping ((_ photos: [String]) -> Void),
                   failure: @escaping ((_ error: FacebookErrorType) -> Void)) {

        if let viewController = viewController as? UIViewController {
            
            let hasToken = (FBSDKAccessToken.current() != nil)
            if (hasToken) {
                
                let hasEnough = (photosUrls.count >= numOfPhotos)
                if (hasEnough) {
                    let random = self.photosUrls[randomPick: numOfPhotos]
                    success(random)
                } else {
                    getUserPhotos(numOfPhotos: numOfPhotos, success: success, failure: failure)
                }

            } else {
                
                loginAndGetUserPhotos(numOfPhotos: numOfPhotos,
                                      withViewController: viewController,
                                      success: success,
                                      failure: failure)
            }

        } else {
            
            failure(.notViewController)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func loginAndGetUserPhotos(numOfPhotos: Int,
                                           withViewController viewController: AnyObject,
                                           success: @escaping ((_ photos: [String]) -> Void),
                                           failure: @escaping ((_ error: FacebookErrorType) -> Void)) {
    
        if let viewController = viewController as? UIViewController {
            
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: permissions,
                                 from: viewController,
                                 handler: { (result, error) in

                                    if (error != nil) {
                                        self.getUserPhotos(numOfPhotos: numOfPhotos, success: success, failure: failure)
                                    } else {
                                        failure(.unknown)
                                    }
            })
        }
    }
    
    fileprivate func getUserPhotos(after: String = "",
                                   numOfPhotos: Int,
                                   success: @escaping ((_ photos: [String]) -> Void),
                                   failure: @escaping ((_ error: FacebookErrorType) -> Void)) {
        
        var parameters = ["type": "uploaded", "fields": "images"]
        if (!after.isEmpty) {
            parameters["after"] = after
        }
        let request = FBSDKGraphRequest.init(graphPath: "me/photos", parameters: parameters)
        
        _ = request?.start(completionHandler: { (connection, result, error) in
            
            if (error == nil) {

                if let dictionary = result as? Dictionary<String, AnyObject> {
                    if let data = dictionary["data"] as? [AnyObject] {
                        let urls = self.getUrls(fromPhotos: data)
                        self.photosUrls.append(contentsOf: urls)
                    }

                    if let paging = dictionary["paging"] as? Dictionary<String, AnyObject>,
                        let cursors = paging["cursors"] as? Dictionary<String, AnyObject>,
                        let after = cursors["after"] as? String {
                        self.getUserPhotos(after: after, numOfPhotos: numOfPhotos, success: success, failure: failure)
                    } else {
                        let enough = (self.photosUrls.count >= numOfPhotos)
                        if (enough) {
                            let random = self.photosUrls[randomPick: numOfPhotos]
                            success(random)
                        } else {
                            failure(.notEnough)
                        }
                    }
                }
                
            } else {
                
                failure(.downloading)
            }
        })
    }
    
    fileprivate func getUrls(fromPhotos photos: [AnyObject]) -> [String] {
        
        var urls = [String]()
        
        _ = photos.map({
            if let onePhoto = $0 as? Dictionary<String, AnyObject> {
                
                let images = onePhoto["images"] as? [AnyObject]
                let maxResolution: Int32 = 320
                var higherResolution: Int32 = 0
                var source = ""
                
                for oneImage in images! {
                    if let height = oneImage["height"] as? Int32, let imageSource = oneImage["source"] as? String {
                        let isBetterResolution = (higherResolution == 0) || ((height > higherResolution) && (height <= maxResolution)) ||
                            ((higherResolution > maxResolution) && (height <= maxResolution))
                        if (isBetterResolution) {
                            higherResolution = height
                            source = imageSource
                        }
                    }
                }
                
                urls.append(source)
            }
        })
        
        return urls
    }
}
