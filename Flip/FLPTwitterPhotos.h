//
//  FLPTwitterPhotos.h
//  Flip
//
//  Created by Jaime on 01/04/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION @"FLPWebLoginViewControllerTwitterCanceledNotification"

@interface FLPTwitterPhotos : NSObject

- (void)getPhotos:(NSInteger)numberOfPhotos success:(void(^)(NSArray* photos))success failure:(void(^)())failure;

@end
