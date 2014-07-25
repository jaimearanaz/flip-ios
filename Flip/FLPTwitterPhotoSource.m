//
//  FLPTwitterPhotoSource.m
//  Flip
//
//  Created by Jaime on 25/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <AFOAuth1Client/AFOAuth1Client.h>

#import "FLPTwitterPhotoSource.h"

#import "STTwitterAPI.h"

@interface FLPTwitterPhotoSource()

@property (nonatomic) NSString *secretKey;
@property (nonatomic) NSString *consumerKey;
@property (nonatomic) NSString *oauthToken;
@property (nonatomic) NSString *oauthTokenSecret;
@property (nonatomic) NSString *screenName;

@end

@implementation FLPTwitterPhotoSource

- (id)initWithOAuthConsumerKey:(NSString *)consumerKey
                consumerSecret:(NSString *)consumerSecret
                    oauthToken:(NSString *)oauthToken
              oauthTokenSecret:(NSString *)oauthTokenSecret
                     screeName:(NSString *)screenName
{
    self = [super init];
    if (self) {
        self.internetRequired = YES;
        self.secretKey = consumerSecret;
        self.consumerKey = consumerKey;
        self.oauthToken = oauthToken;
        self.oauthTokenSecret = oauthTokenSecret;
        self.screenName = screenName;
    }
    return self;
}

- (void)getPhotosFromSource:(NSInteger)number succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure
{
 
    if ((!_consumerKey) || (!_secretKey) || (!_oauthToken) || (!_oauthTokenSecret) || (!_screenName)) {
        FLPLogError(@"some field is missing, use custom init method");
        failure([NSError errorWithDomain:@"" code:0 userInfo:nil]);
        return;
    }
    
    FLPLogDebug(@"number: %ld", number);
    NSMutableArray __block *photos = [[NSMutableArray alloc] init];

    STTwitterAPI *twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKey
                                                            consumerSecret:_secretKey
                                                                oauthToken:_oauthToken
                                                          oauthTokenSecret:_oauthTokenSecret];
    
    // Obtener todos los friends y followers
    // Seleccionar |number| friends al azar
    // Obtener las fotos de esos friends
    
    // First, get friends from Twitter
    // Second, get followers from Twitter
    // Third, get random friends and followers
    // Fourth, get photos from random friends and followers
    
    // TODO: friends and followers are return in 5000 users per page, use pagination for bigger Twitter accounts?
    
    // First, get friends from Twitter
    [twitterAPI getFriendsIDsForScreenName:_screenName
                              successBlock:^(NSArray *friends) {
                                  FLPLogDebug(@"number of friends: %ld", friends.count);
                                  
                                  // Second, get followers from Twitter
                                  [twitterAPI getFollowersIDsForScreenName:_screenName
                                                              successBlock:^(NSArray *followers) {
                                                                  FLPLogDebug(@"number of followers: %ld", followers.count);

                                                                  // Select random friends and followers
                                                                  NSArray *users = [self selectUsers:number
                                                                                         fromFriends:friends
                                                                                         andFollowers:followers];
                                                                  
                                                                  FLPLogDebug(@"number of selected users: %ld", users.count);
                                                                  
                                                                  
                                                                  success(photos);
                                                              }
                                                                errorBlock:^(NSError *error) {
                                                                    FLPLogError(@"error getting followers: %@", [error localizedDescription]);
                                                                    failure(error);
                                                                }];
                                  
                              } errorBlock:^(NSError *error) {
                                  FLPLogError(@"error getting friends: %@", [error localizedDescription]);
                                  failure(error);
                              }];
    
}

/**
 *  Selects random users between friends and followers.
 *  @param number    Number of users to select. If friends and followers aren't enough, returns all of them.
 *  @param friends   List of friends
 *  @param followers List of followers
 *  @return Selected random users between friends and followers
 */
- (NSArray *)selectUsers:(NSInteger)number fromFriends:(NSArray *)friends andFollowers:(NSArray *)followers
{
    // Join friends and users
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [users addObjectsFromArray:friends];
    [users addObjectsFromArray:followers];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // Friends and followers aren't enough, return all of them
    if (users.count < number) {
        result = users;
        FLPLogDebug(@"not enough users, return all");
        
    // Select randomly users
    } else {
        for (int i = 0; i < number; i++) {
            NSInteger randomIndex = arc4random() % users.count;
            [result addObject:[users objectAtIndex:randomIndex]];
            FLPLogDebug(@"add user id %@", [users objectAtIndex:randomIndex]);
        }
    }
    
    return result;
}

@end
