//
//  FLPAppDelegate.m
//  Flip
//
//  Created by Jaime Aranaz on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPAppDelegate.h"

#import <AFNetworking/AFNetworking.h>
#import "AFOAuth1Client.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation FLPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.backgroundColor = [UIColor whiteColor];
    Router *router = [Router sharedInstance];
    self.window.rootViewController = router.navigationController;
    [self.window makeKeyAndVisible];
    [router presenMain];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    BOOL isSmallScreen = ([DWPDevice isiPhone4Inches] || [DWPDevice isiPhone4_7Inches]);
    if (isSmallScreen) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL isFacebookUrl = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                        openURL:url
                                                              sourceApplication:sourceApplication
                                                                     annotation:annotation];
    if (isFacebookUrl) {

        return YES;
        
    } else if ([self isUrlFromTwitterLogin:url]) {
        
        BOOL userHasCanceled = ([[url absoluteString] rangeOfString:@"denied="].location != NSNotFound);
        
        if (userHasCanceled) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION object:nil];

        } else {

            NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification
                                                                         object:nil
                                                                       userInfo:@{kAFApplicationLaunchOptionsURLKey: url}];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        return YES;
    }
    
    return NO;
}

#pragma mark - Private methods

- (bool)isUrlFromTwitterLogin:(NSURL *)url
{
    return ([[url scheme] rangeOfString:@"mobioakflip"].location != NSNotFound);
}

@end
