//
//  FLPPhotoSource.m
//  Flip
//
//  Created by Jaime on 16/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPPhotoSource.h"

@implementation FLPPhotoSource


- (void)getPhotosFromSource:(NSInteger)number succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure
{

}

- (void)getPhotosFromSourceSuccesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure
{
    
}

- (BOOL)photosInLocal
{
    return NO;
}

- (void)getPhotosFromLocalFinishBlock:(void(^)(NSArray* photos))finish;
{

}

- (void)savePhotosToLocal:(NSArray *)photos
{

}

- (NSArray *)updatePhotosFromSource
{
    return nil;
}

- (void)deleteLocal
{
    
}

@end
