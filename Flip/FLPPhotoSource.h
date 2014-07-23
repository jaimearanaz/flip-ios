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
 * The source may have a remote origin though Internet, so |internetRequired| indicates that an Internet connection is needed.
 * If |internetRequired| is set to YES, use appropriate methods to storage and recover photos from local, and save connections.
 */
@interface FLPPhotoSource : NSObject

// YES, if this resource requires an Internet connection to get photos from origin
// NO, if an Internet connection is not needed
@property (nonatomic) BOOL internetRequired;

/**
 * Returns the specified number of photos from source.
 * Maybe an Internet connection is needed; that situation is indicated by |internetRequired|.
 * @param index number of photos to get from the original source
 * @return Array with the specified number of photos, or less if there aren't enough in source
 */
- (NSArray *)getPhotosFromSource:(NSInteger)number;

/**
 * Returns all the available photos from the source.
 * Maybe an Internet connection is needed; that situation is indicated by |internetRequired|.
 * @return Array with all available photos from the source
 */
- (NSArray *)getPhotosFromSource;

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
