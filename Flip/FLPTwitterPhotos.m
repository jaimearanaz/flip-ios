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

#define kMaxFollowingsPerRequest 100

@interface FLPTwitterPhotos()

@property (nonatomic) NSString *secretKey;
@property (nonatomic) NSString *consumerKey;
@property (nonatomic) NSString *oauthToken;
@property (nonatomic) NSString *oauthTokenSecret;
@property (nonatomic) NSString *screenName;
@property (nonatomic, copy, nullable) void (^failureBlock)(TwitterErrorType error);
@property (nonatomic, nullable) STTwitterAPI *twitterApi;
@property (nonatomic) NSInteger numberOfPhotos;
@property (strong, nonatomic) NSArray *photosUrls;
@property (strong, nonatomic) NSDictionary *accountInfo;

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
    self.failureBlock = failure;
    self.numberOfPhotos = numberOfPhotos;
    BOOL userIsLogged = (self.accountInfo != nil);
    
    if (userIsLogged) {
        [self getLoggedUserPhotosWithSuccess:success failure:failure];
    } else {
        [self getNotLoggedUserPhotosWithSuccess:success failure:failure];
    }
}

#pragma mark - Private methods

- (void)getLoggedUserPhotosWithSuccess:(void(^)(NSArray* photos))success failure:(void(^)(TwitterErrorType error))failure
{
    BOOL hasEnough = ((self.photosUrls) && (self.photosUrls.count >= self.numberOfPhotos));
    if (hasEnough) {
        NSArray *urls = [self.photosUrls selectRandom:self.numberOfPhotos];
        success(urls);
    } else {
        [self getFollowingsWithSuccess:success failure:failure];
    }
}

- (void)getNotLoggedUserPhotosWithSuccess:(void(^)(NSArray* photos))success failure:(void(^)(TwitterErrorType error))failure
{
    [PFTwitterSignOn setCredentialsWithConsumerKey:self.consumerKey andSecret:self.secretKey];
    [self subscribeToTwitterCancelNotifications];
    
    // Ways to login in Twitter:
    // 1) there is one or more accounts setup in the device settings
    // 2) use a webview with Twitter official login page; AppDelegate will be called with the response and will launch a notification to us
    
    [PFTwitterSignOn requestAuthenticationWithSelectCallback:^(NSArray *accounts, twitterAccountCallback callback) {
        
        // User has more than one account in the device, so show action sheet to pick one
        
        [self showActionSheetWithAccounts:accounts
                                  success:^(ACAccount *selectedAccount) {
                                      callback(selectedAccount);
                                  } failure: failure];
        
    } andCompletion:^(NSDictionary *accountInfo, NSError *error) {
        
        // User logged in, via device account or Twitter website
        
        [self unsubscribeFromTwitterCancelNotifications];
        
        if (!error) {
            self.accountInfo = accountInfo;
           [self getLoggedUserPhotosWithSuccess:success failure:failure];
        } else {
            failure(TwitterErrorUnknown);
        }
    }];
}

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

- (void)getFollowingsWithSuccess:(void(^)(NSArray *photos))success
                         failure:(void(^)(TwitterErrorType error))failure
{
    BOOL validAccountInfo = (self.accountInfo != nil) && (self.accountInfo.count >= 3);
    
    if (!validAccountInfo) {
        failure(TwitterErrorUnknown);
        return;
    }
    
    self.oauthToken = self.accountInfo[@"accessToken"];
    self.oauthTokenSecret = self.accountInfo[@"tokenSecret"];
    self.screenName = self.accountInfo[@"screen_name"];
    
    self.twitterApi = [STTwitterAPI twitterAPIWithOAuthConsumerKey:self.consumerKey
                                                    consumerSecret:self.secretKey
                                                        oauthToken:self.oauthToken
                                                  oauthTokenSecret:self.oauthTokenSecret];
    
    [self.twitterApi getFriendsIDsForScreenName:self.screenName
                                   successBlock:^(NSArray *followings) {
                                       [self getDescriptionForFollowings:followings succes:success failure:failure];
                                   } errorBlock:^(NSError *error) {
                                         failure(TwitterErrorUnknown);
                                     }];
}

- (void)getDescriptionForFollowings:(NSArray *)followings
                             succes:(void(^)(NSArray *photos))success
                            failure:(void(^)(TwitterErrorType error))failure
{
    NSMutableArray *all = [[NSMutableArray alloc] init];
    [self getAllDescriptionsForFollowings:followings
                             descriptions:all
                                lastIndex:0
                                   succes:^(NSArray *descriptions) {
                                      
                                       BOOL areEnough = (descriptions.count >= self.numberOfPhotos);
                                       if (areEnough) {
                                           
                                           self.photosUrls = [self getURLsFromDescriptions:descriptions];
                                           NSArray *urls = [self.photosUrls selectRandom:self.numberOfPhotos];
                                           success(urls);
                                           
                                       } else {
                                           
                                           failure(TwitterErrorNotEnough);
                                       }
                                       
                                   } failure:^(TwitterErrorType error) {
                                       
                                   }];
}

- (void)getAllDescriptionsForFollowings:(NSArray *)followings
                           descriptions:(NSMutableArray *)allDescriptions
                              lastIndex:(NSInteger)lastIndex
                                 succes:(void(^)(NSArray *descriptions))success
                                failure:(void(^)(TwitterErrorType error))failure
{
    BOOL lastCall = ((lastIndex + kMaxFollowingsPerRequest) >= followings.count);
    NSInteger length = (lastCall) ? (followings.count - lastIndex) : kMaxFollowingsPerRequest;
    NSRange range = NSMakeRange(lastIndex, length);
    NSArray *subFollowings = [followings subarrayWithRange:range];
    NSString *ids = [subFollowings componentsJoinedByString:@","];
    
    [self.twitterApi getUsersLookupForScreenName:nil
                                        orUserID:ids
                                 includeEntities:0
                                    successBlock:^(NSArray *descriptions) {
                                        
                                        NSArray *validUsers = [self filterUsersWithAvatar:descriptions];
                                        NSArray *partialDescriptions = [allDescriptions arrayByAddingObjectsFromArray:validUsers];
                                        NSMutableArray *newAllDescriptions = [NSMutableArray arrayWithArray:partialDescriptions];
                                        BOOL moreFollowings = (length == kMaxFollowingsPerRequest);
                                        
                                        if (moreFollowings) {
                                            
                                            [self getAllDescriptionsForFollowings:followings
                                                                     descriptions:newAllDescriptions
                                                                        lastIndex:lastIndex + length
                                                                           succes:success
                                                                          failure:failure];
                                        } else {
                                            
                                            success(newAllDescriptions);
                                        }
                                        
                                    } errorBlock:^(NSError *error) {
                                        
                                        failure(TwitterErrorUnknown);
                                    }];
}

- (NSArray *)getURLsFromDescriptions:(NSArray *)descriptions
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    [descriptions enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull oneUser, NSUInteger idx, BOOL * _Nonnull stop) {
        
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
