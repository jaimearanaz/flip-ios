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
 * The source may have a remote origin through Internet, so |internetRequired| will be set to YES
 * Use appropriate methods to storage and recover photos from local, and save connections.
 */
@interface FLPPhotoSource : NSObject

// YES, if this resource requires an Internet connection to get photos from origin
// NO, if an Internet connection is not needed
@property (nonatomic) BOOL internetRequired;

/**
 * Gets the specified number of photos from source.
 * Maybe an Internet connection is needed; that situation is indicated by |internetRequired|.
 * @param number Number of photos to get from the original source
 * @param success Block to execute if operation is successful; it contains an array of UIImages
 * @param failure Block to execute if operation fails
 */
- (void)getPhotosFromSource:(NSInteger)number succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure;

/**
 * Gets all the available photos from the source.
 * Maybe an Internet connection is needed; that situation is indicated by |internetRequired|.
 * @param success Block to execute if operation is successful; it contains an array of UIImages
 * @param failure Block to execute if operation fails
 */
- (void)getPhotosFromSourceSuccesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure;

/**
 * Returns all the available photos saved in local from source.
 * Photos must be previously saved from source.
 * @return Array with all photos saved in device
 */
- (NSArray *)getPhotosFromLocal;

/**
 * Saves the given photos to local.
 * @param photos Array of photos to be saved in local
 */
- (void)savePhotosToLocal:(NSArray *)photos;

/**
 * Updates the saved photos in local with its original source.
 * @return Array of photos after updating
 */
- (NSArray *)updatePhotosFromSource;

/**
 * Resets all the saved photos in local.
 */
- (void)reset;


@end
