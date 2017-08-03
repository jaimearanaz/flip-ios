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
    
    @objc optional func didProgress(completed: UInt, total: UInt)
    
    func didFinish(completed: UInt, skipped: UInt)
}

@objc class ImageDownloader: NSObject {
    
    // MARK: - Public methods
    
    static func downloadAndCacheImages(_ images: [URL], completion: @escaping ((_ success: Bool) -> Void) = {_ in }) {
        
        SDWebImagePrefetcher.shared().prefetchURLs(images,
                                                   progress: { (completed, total) in})
        { (completed, skipped) in
            let success = (skipped == 0)
            completion(success)
        }
    }
    
    static func downloadAndCacheImages(_ images: [URL], delegate: ImageDownloaderDelegate?) {
        
        SDWebImagePrefetcher.shared().prefetchURLs(images,
                                                   progress: { (completed, total) in
                                                    delegate?.didProgress?(completed: completed, total: total)
        }) { (completed, skipped) in
            delegate?.didFinish(completed: completed, skipped: skipped)
        }
    }
    
    static func cancelDownloads() {
        
        SDWebImagePrefetcher.shared().cancelPrefetching()
    }
    
    static func clearCache() {
        
        SDWebImageManager.shared().imageCache?.clearMemory()
        SDWebImageManager.shared().imageCache?.clearDisk(onCompletion: {})
    }
    
    static func clearFromCache(image: URL) {
        
        SDWebImageManager.shared().imageCache?.removeImage(forKey: image.absoluteString, withCompletion: nil)
    }
    
    static func isInCache(image: URL, completion: @escaping ((_ isInCache: Bool) -> Void) ) {
        
        SDWebImageManager.shared().cachedImageExists(for: image) { (exists) in
            completion(exists)
        }
    }
}
