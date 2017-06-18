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
    
    fileprivate var photosIds = [String]()
    
    // MARK: - Public methods
    
    //fileprivate let permissions = ["public_profile", "user_friends", "email", "user_photos"]
    fileprivate let permissions = ["user_photos"]
    
    func getPhotos(_ numOfPhotos: Int,
                   inViewController viewController: AnyObject,
                   success: @escaping ((_ photos: [String]) -> Void),
                   failure: @escaping ((_ error: FacebookErrorType) -> Void)) {

        if let viewController = viewController as? UIViewController {
            
            let hasToken = (FBSDKAccessToken.current() != nil)
            
            if (hasToken) {

                getUserPhotos()
                
            } else {
                
                loginInFacebook(withViewController: viewController, success: success, failure: failure)
            }

        } else {
            
            failure(.notViewController)
        }
    }
    
    // MARK: - Private methods
    
    func loginInFacebook(withViewController viewController: AnyObject,
                         success: @escaping ((_ photos: [String]) -> Void),
                         failure: @escaping ((_ error: FacebookErrorType) -> Void)) {
    
        if let viewController = viewController as? UIViewController {
            
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: permissions,
                                 from: viewController,
                                 handler: { (result, error) in

                                    if (error != nil) {
                                        
                                        self.getUserPhotos()
                                        
                                    } else {
                                        
                                        failure(.unknown)
                                    }
                                    
            })
            
        }
    }
    
    func getUserPhotos(after: String = "") {
        
        var parameters = ["type": "uploaded", "fields": "id"]
        if (!after.isEmpty) {
            parameters["after"] = after
        }
        let request = FBSDKGraphRequest.init(graphPath: "me/photos", parameters: parameters)
        
        _ = request?.start(completionHandler: { (connection, result, error) in
            
            if (error == nil) {

                if let dictionary = result as? Dictionary<String, AnyObject> {
                 
                    if let data = dictionary["data"] as? [AnyObject] {

                        _ = data.map({
                            
                            if let onePhoto = $0 as? Dictionary<String, String> {
                             
                                self.photosIds.append(onePhoto["id"] ?? "")
                            }
                        })
                    }

                    if let paging = dictionary["paging"] as? Dictionary<String, AnyObject>,
                        let cursors = paging["cursors"] as? Dictionary<String, AnyObject>,
                        let after = cursors["after"] as? String {
                        
                        self.getUserPhotos(after: after)
                        
                    } else {
                        
                        print(self.photosIds.count)
                    }
                }
                
            } else {
                // TODO: error
            }
        })
    }
}
