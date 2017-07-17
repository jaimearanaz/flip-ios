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
#import "NSArray+Extras.h"

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
    }
    
    return self;
}

#pragma mark - Public methods

- (void)getPhotos:(NSInteger)numberOfPhotos success:(void(^)(NSArray* photos))success failure:(void(^)(TwitterErrorType error))failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    self.numberOfPhotos = numberOfPhotos;
    
    [PFTwitterSignOn setCredentialsWithConsumerKey:self.consumerKey andSecret:self.secretKey];
    [self subscribeToTwitterCancelNotifications];
    
    // Two possible ways to login in Twitter:
    // 1) through an account setup in the device, if exists
    // 2) if not, through a webview requesting Twitter login page; AppDelete will be called with the response
    
    [PFTwitterSignOn requestAuthenticationWithSelectCallback:^(NSArray *accounts, twitterAccountCallback callback) {
        
        // User has more than one account in the device, show action sheet to pick one
        
        [self showActionSheetWithAccounts:accounts
                                  success:^(ACAccount *selectedAccount) {
                                      callback(selectedAccount);
                                  } failure: failure];
    
    } andCompletion:^(NSDictionary *accountInfo, NSError *error) {
    
        // User tried login, via device account or Twitter website
        
        [self unsubscribeFromTwitterCancelNotifications];
        
        // Steps to retrieve followings photos:
        // 1. Get followings IDs
        // 2. Get descriptions for these IDs
        // 3. Get avatar URLs from these descriptions
        // 3. Download N avatar photos
        
        if (!error) {
            [self getFollowingsAndContinueWithAccount:accountInfo success:success failure:failure];
        } else {
            failure(TwitterErrorUnknown);
        }
    }];
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
                                       [self getDescriptionsAndContinueWithFollowings:followings succes:success failure:failure];
                                   } errorBlock:^(NSError *error) {
                                         failure(TwitterErrorUnknown);
                                     }];
}

- (void)getDescriptionsAndContinueWithFollowings:(NSArray *)followings
                                          succes:(void(^)(NSArray *photos))success
                                         failure:(void(^)(TwitterErrorType error))failure
{
    [followings selectRandom:100];
    NSArray *randomUsers = [followings selectRandom:100];
    NSString *allUsers = [randomUsers componentsJoinedByString:@","];
    
    [self.twitterApi getUsersLookupForScreenName:nil
                                        orUserID:allUsers
                                 includeEntities:0
                                    successBlock:^(NSArray *descriptions) {
                                        
                                        NSArray *validUsers = [self filterUsersWithAvatar:descriptions];
                                        BOOL areEnough = (validUsers.count >= self.numberOfPhotos);
                                        
                                        if (areEnough) {

                                            NSArray *randomUsers = [validUsers selectRandom:self.numberOfPhotos];
                                            NSArray *urls = [self getURLsFromUsers:randomUsers];
                                            success(urls);
                                            
                                        } else {
                                            
                                            failure(TwitterErrorNotEnough);
                                        }
                                        
                                    } errorBlock:^(NSError *error) {
                                        
                                        failure(TwitterErrorUnknown);
                                    }];
}

- (NSArray *)getURLsFromUsers:(NSArray *)users
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    [users enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull oneUser, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *imageString = [oneUser objectForKey:@"profile_image_url"];
        imageString = [imageString stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        [urls addObject:imageString];
    }];
    
    return urls;
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
