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
    
    // MARK: - Private methods
    
    // TODO: delete?
    fileprivate func downloadImages(fromSource source: GameSource, size: GameSize) {
        
        controllerDelegate.startLoadingState()
        
        let numberOfImages = (size.rawValue / 2)
        var images = [UIImage]()
        
        for index in 1...numberOfImages {
            
            let name = "photo_\(index).jpg"
            let oneImage = UIImage(named: name)
            images.append(oneImage!)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            self.controllerDelegate.stopLoadingState()
//            Router.sharedInstance.presentGrid(withImages: images, andSize: size, completion: {
//                self.controllerDelegate.showSourceView(withAnimation: false)
//            })
        }
    }
    
    fileprivate func getPhotosFromFacebook(forSize size: GameSize) {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getFacebookPhotos(forSize: size,
                                     inViewController: viewController()!,
                                     success: { (images) in
                                        
                                        self.stopLoadingAndPresentGrid(withImages: images, andSize: size)
                                        
        }, failure: { (error) in
            
            self.controllerDelegate.stopLoadingState()
            self.controllerDelegate.showSourceView(withAnimation: true)
            
            // TODO: implement generic method for source erros
            //self.showTwitterError(error, forSize: size)
        })
    }
    
    fileprivate func getPhotosFromTwitter(forSize size: GameSize) {
        
        controllerDelegate.startLoadingState()
        
        dataSource.getTwitterPhotos(forSize: size,
                                    success: { (images) in
                                        
                                        self.stopLoadingAndPresentGrid(withImages: images, andSize: size)
        }, failure: { (error) in
            
            self.controllerDelegate.stopLoadingState()
            self.controllerDelegate.showSourceView(withAnimation: true)
            
            // TODO: implement generic method for source erros
            self.showTwitterError(error, forSize: size)
        })
    }
    
    fileprivate func stopLoadingAndPresentGrid(withImages images: [String], andSize size: GameSize) {
        
        self.controllerDelegate.stopLoadingState()
        Router.sharedInstance.presentGrid(withImages: images, andSize: size, completion: {
            self.controllerDelegate.showSourceView(withAnimation: false)
        })
    }

    fileprivate func showTwitterError(_ error: PhotosErrorType, forSize size: GameSize) {

        switch error {
            
        case .notEnough:
            
            let localized = NSLocalizedString("MAIN_ENOUGH_PHOTOS_TWITTER",
                                              comment: "Error message when user has not enough users in Twitter")
            let numberOfImages = (size.rawValue / 2)
            let message = String(format: localized, numberOfImages)
            controllerDelegate.showMessage(message)
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
    
    fileprivate func showGenericError() {
        
        let message = NSLocalizedString("MAIN_GENERIC_ERROR", comment: "Generic error message for any source of photos")
        controllerDelegate.showMessage(message)
    }
}
