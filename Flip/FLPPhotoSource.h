//
//  FLPPhotoSource.h
//  Flip
//
//  Created by Jaime Aranaz on 16/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class represents a source of photos.
 * The source may have a remote origin through Internet, so |internetRequired| will be set to YES.
 * Use appropriate methods to save and load photos from cache, and save connections.
 */
@interface FLPPhotoSource : NSObject

// YES, if an Internet connection is required to download original photos
@property (nonatomic) BOOL internetRequired;

/**
 *  Initializes a new photo source object
 *  @param internetRequired YES if Internet is required for this source, NO if not
 *  @param cacheFilename    Name for cache files
 *  @return FLPPhotoSource object
 */
- (id)initInternetRequired:(BOOL)internetRequired cacheName:(NSString *)cacheFilename;

/**
 * Gets the specified number of random photos from source.
 * Maybe an Internet connection is needed; that situation is indicated by |internetRequired|.
 * You are encourage to save photos to cache in order to avoid future connections
 * @param number Number of random photos to get from the original source
 * @param success Block to execute if operation is successful; it contains an array of UIImages
 * @param failure Block to execute if operation fails
 */
- (void)getPhotosFromSource:(NSInteger)number succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure;

/**
 * Returns all the available photos saved in cache.
 * @param finish Block to execute when operation is finished, it contains an array of UIImages
 */
- (void)getPhotosFromCacheFinishBlock:(void(^)(NSArray* photos))finish;

/**
 *  Checks if there are photos saved in cache
 *  @return YES if there are photos saved in cache; NO otherwise
 */
- (BOOL)hasPhotosInCache;

/**
 * Saves the given photos in device disk storage.
 * @param photos Array of photos to be saved in device disk
 */
- (void)savePhotosToCache:(NSArray *)photos;

/**
 * Deletes all the saved photos in device disk.
 */
- (void)deleteCache;


@end
