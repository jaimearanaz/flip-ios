//
//  ImageDownloader.swift
//  BaseProject
//
//  Created by Jaime Aranaz on 10/03/2017.
//  Copyright © 2017 Jaime Aranaz. All rights reserved.
//

import Foundation
import SDWebImage

@objc protocol ImageDownloaderDelegate {
    
    func didProgress(completed: UInt, total: UInt)
    
    func didFinish(completed: UInt, skipped: UInt)
}

@objc class ImageDownloader: NSObject {

    // MARK: - Public methods
    
    static func downloadAndCacheImages(_ images: [URL], completion: @escaping ((_ completed: UInt, _ skipped: UInt) -> Void) = {_, _ in }) {
        
        SDWebImagePrefetcher.shared().prefetchURLs(images,
                                progress: { (completed, total) in})
        { (completed, skipped) in
            completion(completed, skipped)
        }
    }
    
    static func downloadAndCacheImages(_ images: [URL], delegate: ImageDownloaderDelegate) {
        
        SDWebImagePrefetcher.shared().prefetchURLs(images,
        progress: { (completed, total) in
            delegate.didProgress(completed: completed, total: total)
        }) { (completed, skipped) in
            delegate.didFinish(completed: completed, skipped: skipped)
        }
    }
    
    static func cancelDownloads() {
        
        SDWebImagePrefetcher.shared().cancelPrefetching()
    }
    
    static func clearCache() {
        
        SDWebImageManager.shared().imageCache?.clearMemory()
        SDWebImageManager.shared().imageCache?.clearDisk(onCompletion: {})
    }
}
