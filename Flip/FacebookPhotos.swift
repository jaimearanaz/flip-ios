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
    
    // MARK: - Public methods
    
    fileprivate let permissions = ["public_profile", "user_friends", "email"]
    
    func getPhotos(_ numOfPhotos: Int,
                   inViewController viewController: AnyObject,
                   success: @escaping ((_ photos: [String]) -> Void),
                   failure: @escaping ((_ error: FacebookErrorType) -> Void)) {

        if let viewController = viewController as? UIViewController {
            
            let hasToken = (FBSDKAccessToken.current() != nil)
            
            if (hasToken) {

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

            })
            
        }
    }
}
