//
//  FLPTwitterPhotoSource.h
//  Flip
//
//  Created by Jaime on 25/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPPhotoSource.h"

@interface FLPTwitterPhotoSource : FLPPhotoSource

- (id)initWithOAuthConsumerKey:(NSString *)consumerKey
                consumerSecret:(NSString *)consumerSecret
                    oauthToken:(NSString *)oauthToken
              oauthTokenSecret:(NSString *)oauthTokenSecret
                     screeName:(NSString *)screenName;

@end
