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
        
        controllerDelegate.startLoadingState()
        
        dataSource.getTwitterPhotos(forSize: size,
                                    success: { (photos) in
                                        
            self.controllerDelegate.stopLoadingState()
                                        
        }, failure: { (error) in
            
            self.controllerDelegate.stopLoadingState()
            self.showTwitterError(error, forSize: size)
            self.controllerDelegate.showSourceView(withAnimation: true)
        })

        //downloadImages(fromSource: source, size: size)
    }
    
    // MARK: - Private methods
    
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
            Router.sharedInstance.presentGrid(withImages: images, andSize: size, completion: {
                self.controllerDelegate.showSourceView(withAnimation: false)
            })
        }
    }

    fileprivate func showTwitterError(_ error: PhotosErrorType, forSize size: GameSize) {

        if (error == .notEnough) {

            let localized = NSLocalizedString("MAIN_ENOUGH_PHOTOS_TWITTER",
                                              comment: "Error message when user has not enough users in Twitter")
            let numberOfImages = (size.rawValue / 2)
            let message = String(format: localized, numberOfImages)
            controllerDelegate.showMessage(message)
            
        } else if (error == .unknown) {
            
            showGenericError()
        }
    }
    
    fileprivate func showGenericError() {
        
        let message = NSLocalizedString("MAIN_GENERIC_ERROR",
                                        comment: "Generic error message for any source of photos")
        controllerDelegate.showMessage(message)
    }
}
