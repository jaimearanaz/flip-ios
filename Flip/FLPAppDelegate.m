//
//  FLPAppDelegate.m
//  Flip
//
//  Created by Jaime on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <AFOAuth1Client/AFOAuth1Client.h>

#import "FLPAppDelegate.h"
#import "FLPLogFormatter.h"
#import "FLPMainScrenViewController.h"

#import "DDASLLogger.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@implementation FLPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self setLogLevels];
    
    return YES;
}

/**
 *  Sets all log frameworks levels
 */
- (void)setLogLevels
{
#ifdef DEBUG
    FLPLogDebug(@"Set debug log levels");
    int appLogLevel = LOG_LEVEL_VERBOSE;
#else
    int appLogLevel = LOG_LEVEL_WARN;
#endif
    
    // App logs
    [DDLog addLogger:[DDASLLogger sharedInstance] withLogLevel:appLogLevel];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:appLogLevel];
    FLPLogFormatter* logFormatter = [FLPLogFormatter new];
    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
    [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];
}

/**
 *  Checks if given callback URL responds to Facebook callback
 *  @return YES if callbac URL respondes to Facebook callback, NO otherwise
 */
- (bool)handleFacebookUrl:(NSURL *)callbackUrl
{
    return NO;//[FBSession.activeSession handleOpenURL:url];
}

/**
 *  Checks if given callback URL responds to Twitter callback
 *  @return YES if callbac URL respondes to Twitter callback, NO otherwise
 */
- (bool)handleTwitterUrl:(NSURL *)callbackUrl
{
    return ([[callbackUrl scheme] rangeOfString:@"mobioakflip"].location != NSNotFound);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    FLPLogDebug(@"url %@", url);
    
    // Callback from Facebook web login
    if ([self handleFacebookUrl:url]) {
        return YES;
        
    // Callback from Twitter web login
    } else if ([self handleTwitterUrl:url]) {
        
        // User has canceled Twitter login
        if ([[url absoluteString] rangeOfString:@"denied="].location != NSNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION object:nil];
            
        // User logged successfuly in Twitter web
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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
