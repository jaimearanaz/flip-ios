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
    
    fileprivate let reachabilityHost = "www.google.com"
    fileprivate var controllerDelegate: MainViewControllerDelegate!
    fileprivate var router: RouterDelegate!
    fileprivate var dataSource: DataSourceDelegate!
    fileprivate var gameSource = GameSource.unkown
    fileprivate var gameSize = GameSize.unkown
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
        
        gameSource = source
        gameSize = size
        
        switch source {
        case .twitter,
             .facebook:
            checkReachabilityAndGetPhotos()
            break
        case .camera:
            getPhotosFromCamera()
            break
        default: break
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func checkReachabilityAndGetPhotos() {
        
        let reachability = Reachability(hostName: reachabilityHost)
        let isConnectionAvailable = (reachability?.currentReachabilityStatus() != NotReachable)
        
        if (isConnectionAvailable) {
            checkConnectionTypeAndGetPhotos()
        } else {
            let message = NSLocalizedString("MAIN_INERNET_CONNECTION", comment: "Error when there is no connection")
            controllerDelegate.showMessage(message)
        }
    }
    
    fileprivate func checkConnectionTypeAndGetPhotos() {
        
        let reachability = Reachability(hostName: reachabilityHost)
        let underWifi = (reachability?.currentReachabilityStatus() == ReachableViaWiFi)
        
        if (underWifi) || (is3GAllowed) {
            getPhotosFromRemote()
        } else {
            show3GWarningBeforeGettingPhotos()
        }
    }
    
    fileprivate func show3GWarningBeforeGettingPhotos() {
        
        controllerDelegate.show3GWarningMessage(yes: {
            is3GAllowed = true
            getPhotosFromRemote()
        }, no: {
            is3GAllowed = false
        })
    }
    
    fileprivate func getPhotosFromRemote() {
        
        if (gameSource == .twitter) {
            getPhotosFromTwitter()
        } else {
            getPhotosFromFacebook()
        }
    }

    fileprivate func getPhotosFromFacebook() {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getFacebookPhotos(forSize: gameSize,
                                     inViewController: viewController()!,
                                     success: { (images) in
                                        
                                        self.downloadImagesAndPresentGrid(images: images)
                                        
        }, failure: { (error) in
            
            self.stopLoadingAndShowError(error: error)
        })
    }
    
    fileprivate func getPhotosFromTwitter() {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getTwitterPhotos(forSize: gameSize,
                                    success: { (images) in
                                        
                                        self.downloadImagesAndPresentGrid(images: images)
        }, failure: { (error) in
            
            self.stopLoadingAndShowError(error: error)
        })
    }
    
    fileprivate func getPhotosFromCamera() {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getCameraPhotos(forSize: gameSize,
                                   success: { (images) in
                                    
                                    self.controllerDelegate.stopLoadingState()
                                    
        }, failure: { (error) in
            
            self.stopLoadingAndShowError(error: error)
        })
    }
    
    fileprivate func downloadImagesAndPresentGrid(images: [String]) {
        
        var urls = [URL]()
        _ = images.map {
            urls.append(URL(string: $0)!)
        }
        
        ImageDownloader.downloadAndCacheImages(urls, completion: { (success) in
            if (success) {
                self.stopLoadingAndPresentGrid(withImages: images)
            } else {
                self.stopLoadingAndShowError(error: .downloading)
            }
        })
    }
    
    fileprivate func stopLoadingAndPresentGrid(withImages images: [String]) {
        
        self.controllerDelegate.stopLoadingState()
        Router.sharedInstance.presentGrid(withImages: images, andSize: gameSize, completion: {
            self.controllerDelegate.showSourceView(withAnimation: false)
        })
    }
    
    fileprivate func stopLoadingAndShowError(error: PhotosErrorType) {
        
        self.controllerDelegate.stopLoadingState()
        self.controllerDelegate.showSourceView(withAnimation: true)
        self.showError(error)
    }

    fileprivate func showError(_ error: PhotosErrorType) {

        switch error {
            
        case .notEnough:
            
            showNotEnoughError()
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
    
    fileprivate func showNotEnoughError() {
        
        var message = ""
        
        switch gameSource {
            
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
        default:
            break
        }
        
        controllerDelegate.showMessage(message)
    }
    
    fileprivate func showGenericError() {
        
        let message = NSLocalizedString("MAIN_GENERIC_ERROR", comment: "Generic error message for any source of photos")
        controllerDelegate.showMessage(message)
    }
}
