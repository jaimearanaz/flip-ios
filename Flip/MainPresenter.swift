//
//  MainPresenter.swift
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

import Foundation
import UIKit

class MainPresenter: FLPBasePresenter, MainPresenterDelegate {
    
    fileprivate var controllerDelegate: MainViewControllerDelegate!
    fileprivate var router: RouterDelegate!
    fileprivate var dataSource: DataSourceDelegate!
    fileprivate var is3GAllowed = false
    
    // MARK: - Public methods
    
    func setupPresenter(controllerDelegate: MainViewControllerDelegate,
                        dataSource: DataSourceDelegate,
                        router: RouterDelegate) {
        
        self.controllerDelegate = controllerDelegate
        self.dataSource = dataSource
        self.router = router
    }
    
    func showRecords() {
        
        dataSource.getRecords { (records) in
            controllerDelegate.showRecords(records)
        }
    }
    
    func viewController() -> UIViewController? {
        
        return controllerDelegate as? UIViewController
    }
    
    // MARK: - MainPresenterDelegate methods
    
    func didSelectOptions(source: GameSource, size: GameSize) {
        
        let reachability = Reachability(hostName: "www.google.com")
        let underWifi = reachability?.currentReachabilityStatus() == ReachableViaWiFi
        
        if (underWifi) || (is3GAllowed) {
            getPhotos(forSource: source, andSize: size)
        } else {
            show3GWarningBeforeGetPhotos(forSource: source, andSize: size)
        }
    }
    
    fileprivate func getPhotos(forSource source: GameSource, andSize size: GameSize) {
        
        switch source {
            
        case .twitter:
            getPhotosFromTwitter(forSize: size)
            break
        case .facebook:
            getPhotosFromFacebook(forSize: size)
            break
        default: break
        }
    }
    
    fileprivate func show3GWarningBeforeGetPhotos(forSource source: GameSource, andSize size: GameSize) {
        
        controllerDelegate.show3GWarningMessage(yes: {
            is3GAllowed = true
            getPhotos(forSource: source, andSize: size)
        }, no: {
            is3GAllowed = false
        })
    }
    
    // MARK: - Private methods

    fileprivate func getPhotosFromFacebook(forSize size: GameSize) {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getFacebookPhotos(forSize: size,
                                     inViewController: viewController()!,
                                     success: { (images) in
                                        
                                        self.downloadImagesAndPresentGrid(images: images, forSource: .facebook, andSize: size)
                                        
        }, failure: { (error) in
            
            self.stopLoadingAndShowError(error: error, forSource: .facebook, andSize: size)
        })
    }
    
    fileprivate func getPhotosFromTwitter(forSize size: GameSize) {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getTwitterPhotos(forSize: size,
                                    success: { (images) in
                                        
                                        self.downloadImagesAndPresentGrid(images: images, forSource: .twitter, andSize: size)
        }, failure: { (error) in
            
            self.stopLoadingAndShowError(error: error, forSource: .twitter, andSize: size)
        })
    }
    
    fileprivate func downloadImagesAndPresentGrid(images: [String], forSource source: GameSource, andSize size: GameSize) {
        
        var urls = [URL]()
        _ = images.map {
            urls.append(URL(string: $0)!)
        }
        
        ImageDownloader.downloadAndCacheImages(urls, completion: { (success) in
            if (success) {
                self.stopLoadingAndPresentGrid(withImages: images, andSize: size)
            } else {
                self.stopLoadingAndShowError(error: .downloading, forSource: source, andSize: size)
            }
        })
    }
    
    fileprivate func stopLoadingAndPresentGrid(withImages images: [String], andSize size: GameSize) {
        
        self.controllerDelegate.stopLoadingState()
        Router.sharedInstance.presentGrid(withImages: images, andSize: size, completion: {
            self.controllerDelegate.showSourceView(withAnimation: false)
        })
    }
    
    fileprivate func stopLoadingAndShowError(error: PhotosErrorType, forSource source: GameSource, andSize size: GameSize) {
        
        self.controllerDelegate.stopLoadingState()
        self.controllerDelegate.showSourceView(withAnimation: true)
        self.showError(error, forSource: source, andSize: size)
    }

    fileprivate func showError(_ error: PhotosErrorType, forSource source: GameSource, andSize size: GameSize) {

        switch error {
            
        case .notEnough:
            
            showNotEnoughError(forSource: source)
            break
            
        case .cancelled:
            
            let message = NSLocalizedString("MAIN_CANCELLED_LOGIN", comment: "Error message when user has cancelled login")
            controllerDelegate.showMessage(message)
            break
            
        case .downloading:
            
            let message = NSLocalizedString("MAIN_ERROR_DOWNLOADING", comment: "Error message when photos downloading fails")
            controllerDelegate.showMessage(message)
            break
            
        default:
            
            showGenericError()
            break
        }
    }
    
    fileprivate func showNotEnoughError(forSource source: GameSource) {
        
        var message = ""
        
        switch source {
            
        case .twitter:
            message = NSLocalizedString("MAIN_ENOUGH_PHOTOS_TWITTER",
                                        comment: "Error message when user has not enough followings in Twitter")
            break
        case .facebook:
            message = NSLocalizedString("MAIN_ENOUGH_PHOTOS_FACEBOOK",
                                        comment: "Error message when user has not enough friends in Facebook")
            break
        case .camera:
            message = NSLocalizedString("MAIN_ENOUGH_PHOTOS_CAMERA",
                                        comment: "Error message when user has not enough photos in Camera")
            break
        }
        
        controllerDelegate.showMessage(message)
    }
    
    fileprivate func showGenericError() {
        
        let message = NSLocalizedString("MAIN_GENERIC_ERROR", comment: "Generic error message for any source of photos")
        controllerDelegate.showMessage(message)
    }
}
