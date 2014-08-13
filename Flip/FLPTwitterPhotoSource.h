//
//  FLPTwitterPhotoSource.h
//  Flip
//
//  Created by Jaime on 25/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPPhotoSource.h"

/**
 * This class represents a Twitter photo source. Internet connection is required
 */
@interface FLPTwitterPhotoSource : FLPPhotoSource

/**
 *  Initializes the Twitter photo source with the needed data to establish valid connection with API
 *  @param consumerKey      A valid consumer key to access Twitter API, provided by Twitter
 *  @param consumerSecret   A valid consumer secret to access Twitter API, provided by Twitter
 *  @param oauthToken       A valid token to access Twitter API, provided after login
 *  @param oauthTokenSecret A valid token secret to access Twitter API, provided after login
 *  @param screenName       A valid screen name
 *  @return FLPTwitterPhotoSource object ready to use
 */
- (id)initWithOAuthConsumerKey:(NSString *)consumerKey
                consumerSecret:(NSString *)consumerSecret
                    oauthToken:(NSString *)oauthToken
              oauthTokenSecret:(NSString *)oauthTokenSecret
                     screeName:(NSString *)screenName;

@end
