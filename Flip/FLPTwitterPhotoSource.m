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
@property (nonatomic) STTwitterAPI *twitterApi;

@end

@implementation FLPTwitterPhotoSource

- (id)initWithOAuthConsumerKey:(NSString *)consumerKey
                consumerSecret:(NSString *)consumerSecret
                    oauthToken:(NSString *)oauthToken
              oauthTokenSecret:(NSString *)oauthTokenSecret
                     screeName:(NSString *)screenName
{
    self = [super initInternetRequired:YES cacheName:@"twitter"];
    if (self) {
        self.secretKey = consumerSecret;
        self.consumerKey = consumerKey;
        self.oauthToken = oauthToken;
        self.oauthTokenSecret = oauthTokenSecret;
        self.screenName = screenName;
    }
    return self;
}

#pragma mark - FLPPhotoSource superclass methods

- (void)getRandomPhotosFromSource:(NSInteger)number
                      succesBlock:(void(^)(NSArray* photos))success
                     failureBlock:(void(^)(NSError *error))failure
{
 
    if ((!_consumerKey) || (!_secretKey) || (!_oauthToken) || (!_oauthTokenSecret) || (!_screenName)) {
        FLPLogError(@"some field is missing, use custom init method");
        failure([NSError errorWithDomain:@"" code:0 userInfo:nil]);
        return;
    }
    
    FLPLogDebug(@"number: %ld", number);

    _twitterApi = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKey
                                                            consumerSecret:_secretKey
                                                                oauthToken:_oauthToken
                                                          oauthTokenSecret:_oauthTokenSecret];
    
    // Steps:
    // 1. get friends from Twitter
    // 2. get followers from Twitter
    // 3. get random friends and followers
    // 4. get photos from random friends and followers
    
    // TODO: friends and followers are return in 5000 users per page, paginate?
    // TODO: lookup users are return in 200 users per page, paginate?
    // TODO: users can have "default_profile_image" set to TRUE (egg image), filter?
    
    // 1. get friends from Twitter
    [_twitterApi getFriendsIDsForScreenName:_screenName
                              successBlock:^(NSArray *friends) {
                                  FLPLogDebug(@"number of friends: %ld", friends.count);
                                  
                                  // 2. get followers from Twitter
                                  [_twitterApi getFollowersIDsForScreenName:_screenName
                                                              successBlock:^(NSArray *followers) {
                                                                  FLPLogDebug(@"number of followers: %ld", followers.count);

                                                                  if ((friends.count + followers.count) >= number) {
                                                                      
                                                                      // 3. get random friends and followers
                                                                      NSArray *randomUsers = [self selectUsers:number
                                                                                                   fromFriends:friends
                                                                                                  andFollowers:followers];

                                                                      // 4. get photos from random friends and followers
                                                                      [self downloadPhotosForUsers:randomUsers
                                                                                       succesBlock:^(NSArray *photos) {
                                                                                           success(photos);
                                                                                       }
                                                                                      failureBlock:^(NSError *error) {
                                                                                          FLPLogDebug(@"error: %@", [error localizedDescription]);
                                                                                          failure([NSError errorWithDomain:@""
                                                                                                                      code:kErrorDownloadingPhotos
                                                                                                                  userInfo:nil]);
                                                                                      }];
                                                                
                                                                  // There are no enough friends and folloers on Twitter
                                                                  } else {
                                                                      failure([NSError errorWithDomain:@""
                                                                                                  code:KErrorEnoughPhotos
                                                                                              userInfo:nil]);
                                                                  }

                                                              }
                                                                errorBlock:^(NSError *error) {
                                                                    FLPLogDebug(@"error: %@", [error localizedDescription]);
                                                                    failure([NSError errorWithDomain:@""
                                                                                                code:kErrorDownloadingPhotos
                                                                                            userInfo:nil]);
                                                                }];
                                  
                              } errorBlock:^(NSError *error) {
                                  FLPLogDebug(@"error: %@", [error localizedDescription]);
                                  failure([NSError errorWithDomain:@""
                                                              code:kErrorDownloadingPhotos
                                                          userInfo:nil]);
                              }];
    
}

#pragma mark - Private methods

/**
 *  Selects random users between given friends and followers.
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

/**
 *  Downloads profile photos from Twitter API for given users
 *  @param users Users to download their profile photos
 *  @return An array of UIImages with users profile photos
 */
- (NSMutableArray *)getPhotosForUsers:(NSArray *)users
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
            [photos addObject:image];
        } else {
            FLPLogDebug(@"error downloading: %@", [error localizedDescription]);
        }
    }
    
    return photos;
}

/**
 * Gets complete description from Twitter API for given users, and downloads their profile photos
 * @param users   Users to get complete description and download their profile photos
 * @param success Block to execute if operation is successful; it contains an array of UIImages
 * @param failure Block to execute if operation fails
 */
- (void)downloadPhotosForUsers:(NSArray *)users succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure
{
    NSString * usersId = [users componentsJoinedByString:@","];
    
    // TODO: max. of users are 100 per request, paginate?
    
    // Fourth, get photos from random friends and followers
    [_twitterApi getUsersLookupForScreenName:nil
                                   orUserID:usersId
                            includeEntities:0
                               successBlock:^(NSArray *usersLookup) {
                                   FLPLogDebug(@"number of complete users: %ld", usersLookup.count);
                                   NSMutableArray *photos = [[NSMutableArray alloc] init];
                                   photos = [self getPhotosForUsers:usersLookup];
                                   success(photos);
                               } errorBlock:^(NSError *error) {
                                   FLPLogError(@"error getting lookup users: %@", [error localizedDescription]);
                                   failure(error);
                               }];
    
}

@end
