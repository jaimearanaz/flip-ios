//
//  FLPTwitterPhotos.m
//  Flip
//
//  Created by Jaime on 01/04/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPTwitterPhotos.h"

#import <PFTwitterSignOn/PFTwitterSignOn.h>
#import "STTwitterAPI.h"
#import <Accounts/ACAccount.h>

#import "AlertController.h"

@interface FLPTwitterPhotos()

@property (nonatomic) NSString *secretKey;
@property (nonatomic) NSString *consumerKey;
@property (nonatomic) NSString *oauthToken;
@property (nonatomic) NSString *oauthTokenSecret;
@property (nonatomic) NSString *screenName;
@property (nonatomic, copy, nullable) void (^successBlock)(NSArray *photos);
@property (nonatomic, copy, nullable) void (^failureBlock)(TwitterErrorType error);
@property (nonatomic, nullable) STTwitterAPI *twitterApi;
@property (nonatomic) NSInteger numberOfPhotos;

@end

@implementation FLPTwitterPhotos

#pragma mark - Lifecycle methods

- (instancetype)init
{
    self = [super init];
    
    if (self) {
 
        NSString *twitterPlist = [[NSBundle mainBundle] pathForResource:@"TwitterKeys" ofType:@"plist"];
        NSDictionary *twitterKeys = [[NSDictionary alloc] initWithContentsOfFile:twitterPlist];
        _consumerKey = [twitterKeys objectForKey:@"consumerKey"];
        _secretKey = [twitterKeys objectForKey:@"secretKey"];
        
        [self subscribeToTwitterCancelNotifications];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)getPhotos:(NSInteger)numberOfPhotos success:(void(^)(NSArray* photos))success failure:(void(^)(TwitterErrorType error))failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    self.numberOfPhotos = numberOfPhotos;
    
    // Login with Twitter
    // Two ways to login:
    // a) with user account in device, through the selectCallback in this method
    // b) with Twitter login web view, through |application:openURL:sourceApplication:annotation:| method in app delegate
    
    [PFTwitterSignOn setCredentialsWithConsumerKey:self.consumerKey andSecret:self.secretKey];
    [PFTwitterSignOn requestAuthenticationWithSelectCallback:^(NSArray *accounts, twitterAccountCallback callback) {
        
        [self showActionSheetWithAccounts:accounts
                                  success:^(ACAccount *selectedAccount) {
                                      callback(selectedAccount);
                                  } failure: failure];
    
    } andCompletion:^(NSDictionary *accountInfo, NSError *error) {
    
        // Called when logged via web or via local account
        
        [self unsubscribeFromTwitterCancelNotifications];
        
        if (!error) {
            
            [self getFollowingsAndContinueWithAccount:accountInfo
                                              success:success
                                              failure:failure];
        } else {
            
            failure(TwitterErrorUnknown);
        }
        
    }];
    
    [self unsubscribeFromTwitterCancelNotifications];
}

#pragma mark - Private methods

- (void)showActionSheetWithAccounts:(NSArray *)accounts
                            success:(void(^)(ACAccount *selectedAccount))success
                            failure:(void(^)(TwitterErrorType error))failure
{
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    [accounts enumerateObjectsUsingBlock:^(ACAccount * _Nonnull oneAccount, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *username = [NSString stringWithFormat:@"@%@", [oneAccount.username lowercaseString]];
        [usernames addObject:username];
    }];
    
    AlertControllerSheetCancelCompletion selectAccountBlock = ^(NSInteger option) {
        ACAccount *account = accounts[option];
        success(account);
    };
    
    AlertControllerSheetCancelCompletion cancelBlock = ^{
        failure(TwitterErrorCancelled);
    };
    
    NSMutableArray *optionsBlocks = [[NSMutableArray alloc] init];
    for (int i = 0; i < usernames.count; i++) {
        [optionsBlocks addObject:selectAccountBlock];
    }
    
    [AlertController showActionSheetWithMessage:NSLocalizedString(@"MAIN_SELECT_TWITTER", @"Select Twitter account")
                                          title:@""
                                  optionsTitles:usernames
                                  optionsBlocks:optionsBlocks
                                    cancelTitle:NSLocalizedString(@"OTHER_CANCEL", @"Cancel Twitter account selection")
                                    cancelBlock:cancelBlock];
}

- (void)getFollowingsAndContinueWithAccount:(NSDictionary *)accountInfo
                                    success:(void(^)(NSArray *photos))success
                                    failure:(void(^)(TwitterErrorType error))failure
{
    BOOL validAccountInfo = (accountInfo != nil) && (accountInfo.count >= 3);
    
    if (!validAccountInfo) {
        failure(TwitterErrorUnknown);
        return;
    }
    
    self.oauthToken = accountInfo[@"accessToken"];
    self.oauthTokenSecret = accountInfo[@"tokenSecret"];
    self.screenName = accountInfo[@"screen_name"];
    
    self.twitterApi = [STTwitterAPI twitterAPIWithOAuthConsumerKey:self.consumerKey
                                                    consumerSecret:self.secretKey
                                                        oauthToken:self.oauthToken
                                                  oauthTokenSecret:self.oauthTokenSecret];
    
    [self.twitterApi getFriendsIDsForScreenName:self.screenName
                                   successBlock:^(NSArray *followings) {
                                       [self getDescriptionsAndContinueWithFollowings:followings
                                                                               succes:success
                                                                              failure:failure];
                                   } errorBlock:^(NSError *error) {
                                         failure(TwitterErrorUnknown);
                                     }];
}

- (void)getDescriptionsAndContinueWithFollowings:(NSArray *)followings
                                          succes:(void(^)(NSArray *photos))success
                                         failure:(void(^)(TwitterErrorType error))failure
{
    NSArray *randomUsers = [self selectRandom:100 fromUsers:[NSMutableArray arrayWithArray:followings]];
    NSString *allUsers = [randomUsers componentsJoinedByString:@","];
    
    [self.twitterApi getUsersLookupForScreenName:nil
                                        orUserID:allUsers
                                 includeEntities:0
                                    successBlock:^(NSArray *descriptions) {
                                        
                                        NSArray *validUsers = [self filterUsersWithAvatar:descriptions];
                                        BOOL areEnough = (validUsers.count >= self.numberOfPhotos);
                                        
                                        if (areEnough) {
                                            
                                            NSArray *randomUsers = [self selectRandom:self.numberOfPhotos fromUsers:validUsers];
                                            [self downloadPhotosFromUsers:randomUsers
                                                                   succes:success
                                                                  failure:failure];
                                        } else {
                                            failure(TwitterErrorNotEnough);
                                        }

                                        
                                    } errorBlock:^(NSError *error) {
                                        failure(TwitterErrorUnknown);
                                    }];
}

- (void)downloadPhotosFromUsers:(NSArray *)users
                         succes:(void(^)(NSArray* photos))success
                        failure:(void(^)(TwitterErrorType error))failure
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [users enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull oneUser, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *imageString = [oneUser objectForKey:@"profile_image_url"];
        imageString = [imageString stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        [photos addObject:imageString];
        [urls addObject:[NSURL URLWithString:imageString]];
    }];
    
    [ImageDownloader downloadAndCacheImages:urls
                                 completion:^(NSUInteger completed, NSUInteger skipped) {
        
                                     if (completed == urls.count) {
                                         success(photos);
                                     } else {
                                         failure(TwitterErrorUnknown);
                                     }
                                 }];
}

- (NSArray *)filterUsersWithAvatar:(NSArray *)users
{
    NSMutableArray *usersWithAvatar = [[NSMutableArray alloc] init];
    
    [users enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull oneUser, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL hasAvatar = ![[oneUser objectForKey:@"default_profile_image"] boolValue];
        if (hasAvatar) {
            [usersWithAvatar addObject:oneUser];
        }
    }];

    return usersWithAvatar;
}

- (NSArray *)selectRandom:(NSInteger)number fromUsers:(NSArray *)users
{
    NSMutableArray *usersMutable = [NSMutableArray arrayWithArray:users];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    BOOL hasEnoughUsers = (usersMutable.count > number);
    
    if (hasEnoughUsers) {
        
        for (int i = 0; i < number; i++) {
            NSInteger randomIndex = arc4random() % usersMutable.count;
            [result addObject:[usersMutable objectAtIndex:randomIndex]];
            [usersMutable removeObjectAtIndex:randomIndex];
        }
        
    } else {
        
        [result addObjectsFromArray:usersMutable];
    }
    
    return result;
}

- (void)twitterLoginCanceledNotification
{
    self.failureBlock(TwitterErrorCancelled);
    [self unsubscribeFromTwitterCancelNotifications];
}

- (void)subscribeToTwitterCancelNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(twitterLoginCanceledNotification)
                                                 name:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION
                                               object:nil];
}

- (void)unsubscribeFromTwitterCancelNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION
                                                  object:nil];
}

@end