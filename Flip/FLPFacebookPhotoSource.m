//
//  FLPFacebookPhotoSource.m
//  Flip
//
//  Created by Jaime on 29/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPFacebookPhotoSource.h"

@implementation FLPFacebookPhotoSource

- (id)init
{
    self = [super initInternetRequired:YES cacheName:@"facebook"];
    return self;
}

- (void)getRandomPhotosFromSource:(NSInteger)number succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure
{
    
}

- (void)getPhotosFromCacheFinishBlock:(void(^)(NSArray* photos))finish
{
    
}

@end
