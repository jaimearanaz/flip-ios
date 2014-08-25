//
//  FLPTwitterPhotoSource.m
//  Flip
//
//  Created by Jaime Aranaz on 25/07/14.
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
@property (nonatomic) STTwitterAPI *twitterApi;

@end

@implementation FLPTwitterPhotoSource

- (id)init
{
    self = [super initInternetRequired:YES cacheName:@"twitter"];
    return self;
}

- (void)setOauthConsumerKey:(NSString *)consumerKey
             consumerSecret:(NSString *)consumerSecret
                 oauthToken:(NSString *)oauthToken
           oauthTokenSecret:(NSString *)oauthTokenSecret
                  screeName:(NSString *)screenName
{
    self.secretKey = consumerSecret;
    self.consumerKey = consumerKey;
    self.oauthToken = oauthToken;
    self.oauthTokenSecret = oauthTokenSecret;
    self.screenName = screenName;
}

#pragma mark - FLPPhotoSource superclass methods

- (void)getPhotosFromSource:(NSInteger)number
                      succesBlock:(void(^)(NSArray* photos))success
                     failureBlock:(void(^)(NSError *error))failure
{
 
    if ((!_consumerKey) || (!_secretKey) || (!_oauthToken) || (!_oauthTokenSecret) || (!_screenName)) {
        FLPLogError(@"some field is missing, call setOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:screeName: method first!");
        failure([NSError errorWithDomain:@"" code:0 userInfo:nil]);
        return;
    }

    _twitterApi = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKey
                                                            consumerSecret:_secretKey
                                                                oauthToken:_oauthToken
                                                          oauthTokenSecret:_oauthTokenSecret];
    
    // Steps:
    // 1. get friends from Twitter
    // 2. get followers from Twitter
    // 3. get complete description for friends and followers from Twitter
    // 4. discard those with default image profiles (egg image)
    // 5. get |number| random friends and followers
    // 6. download photos from random friends and followers
    
    // TODO: friends and followers are return in 5000 users per page, paginate?
    
    // 1. get friends from Twitter
    [_twitterApi getFriendsIDsForScreenName:_screenName
                              successBlock:^(NSArray *friends) {
                                  FLPLogDebug(@"number of friends: %ld", (unsigned long)friends.count);
                                  
    // 2. get followers from Twitter
    [_twitterApi getFollowersIDsForScreenName:_screenName
                                 successBlock:^(NSArray *followers) {
                                     FLPLogDebug(@"number of followers: %ld", (unsigned long)followers.count);
                                     
    // 3. get complete description for friends and followers from Twitter
                                     
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [users addObjectsFromArray:friends];
    [users addObjectsFromArray:followers];
                                     
    [self getDescriptioForUsers:users
                    succesBlock:^(NSArray *usersDescription) {
                                                         
                        NSMutableArray *completeUsers = [[NSMutableArray alloc] init];
                        
                        // 4. discard those with default image profiles (egg image)
                        for (NSDictionary* user in usersDescription) {
                            BOOL defaultProfile = [[user objectForKey:@"default_profile_image"] boolValue];
                            if (defaultProfile) {
                                FLPLogWarn(@"egg image, skip user");
                                continue;
                            } else {
                                [completeUsers addObject:user];
                            }
                        }
                        
                        if (completeUsers.count >= number) {
                            
                            // 5. get |number| random friends and followers
                            NSArray *randomUsers = [self selectRandom:number fromUsers:completeUsers];
                            
                            // 6. download photos from random friends and followers
                            NSArray *photos = [self downloadPhotosForUsers:randomUsers];
                            
                            // Return photos
                            if (photos.count >= number) {
                                success(photos);
                                
                            // Error downloading some photos
                            } else {
                                FLPLogError(@"not enough downloaded photos");
                                failure([NSError errorWithDomain:@""
                                                            code:kErrorDownloadingPhotos
                                                        userInfo:nil]);
                            }
                            
                        // Not enough complete users
                        } else {
                            FLPLogError(@"not enough complete users");
                            failure([NSError errorWithDomain:@""
                                                        code:KErrorEnoughPhotos
                                                    userInfo:nil]);
                        }
                        
                        
    } failureBlock:^(NSError *error) {
        FLPLogError(@"error: %@", [error localizedDescription]);
        failure([NSError errorWithDomain:@""
                                    code:kErrorDownloadingPhotos
                                userInfo:nil]);
    }];

    } errorBlock:^(NSError *error) {
        FLPLogError(@"error: %@", [error localizedDescription]);
        failure([NSError errorWithDomain:@""
                                    code:kErrorDownloadingPhotos
                                userInfo:nil]);
        }];
                                  
    } errorBlock:^(NSError *error) {
        FLPLogError(@"error: %@", [error localizedDescription]);
        failure([NSError errorWithDomain:@""
                                    code:kErrorDownloadingPhotos
                                userInfo:nil]);
    }];
    
}

#pragma mark - Private methods

/**
 *  Selects a random number of users from the given array
 *  @param number Number of users to select. If users aren't enough, returns all of them.
 *  @param users  List of users
 *  @return Selected random users
 */
- (NSArray *)selectRandom:(NSInteger)number fromUsers:(NSMutableArray *)users
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // Users aren't enough, return all of them
    if (users.count < number) {
        [result addObjectsFromArray:users];
        
    // Select randomly users
    } else {
        for (int i = 0; i < number; i++) {
            NSInteger randomIndex = arc4random() % users.count;
            [result addObject:[users objectAtIndex:randomIndex]];
            [users removeObjectAtIndex:randomIndex];
        }
    }
    
    return result;
}

/**
 *  Downloads profile photos from Twitter API for given users
 *  @param users Users to download their profile photos
 *  @return An array of UIImages with users profile photos
 */
- (NSMutableArray *)downloadPhotosForUsers:(NSArray *)users
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (NSDictionary* user in users) {
        FLPLogDebug(@"add image: %@", [user objectForKey:@"profile_image_url"]);
        
        // default profile photo is "_normal.png"
        // try to download bigger version photo
        NSString *imageUrl = [user objectForKey:@"profile_image_url"];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                    cachePolicy:NSURLCacheStorageAllowed
                                                timeoutInterval:10];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [photos addObject:image];
            } else {
                FLPLogError(@"error generating image %@", imageUrl);
            }
        } else {
            FLPLogError(@"error downloading image %@, error: %@", imageUrl, [error localizedDescription]);
        }
    }
    
    return photos;
}

/**
 *  Gets a complete descriptions from Twitter API for the given list of users IDs
 *  @param usersId List of users IDs
 *  @param succesBlock Block to execute if operation is successful; it contains an array of complete users
 *  @param failureBlock Block to execute if operation fails
 */
- (void)getDescriptioForUsers:(NSArray *)usersId
                  succesBlock:(void(^)(NSArray* usersDescription))success
                 failureBlock:(void(^)(NSError *error))failure
{
    // Select 100 users randomly, request it's up to 100
    NSArray *randomUsers = [self selectRandom:100 fromUsers:[NSMutableArray arrayWithArray:usersId]];
    
    NSString * allUsers = [randomUsers componentsJoinedByString:@","];
    [_twitterApi getUsersLookupForScreenName:nil
                                    orUserID:allUsers
                             includeEntities:0
                                successBlock:^(NSArray *usersLookup) {
                                    success(usersLookup);
                                    
                                } errorBlock:^(NSError *error) {
                                    FLPLogError(@"error getting lookup users: %@", [error localizedDescription]);
                                    failure(error);
                                }];
}

@end
