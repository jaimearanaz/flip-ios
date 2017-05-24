//
//  FLPAppDelegate.m
//  Flip
//
//  Created by Jaime Aranaz on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "AFOAuth1Client.h"

#import "FLPAppDelegate.h"
#import "FLPMainScrenViewController.h"

@implementation FLPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.backgroundColor = [UIColor whiteColor];
    Router *router = [Router sharedInstance];
    self.window.rootViewController = router.navigationController;
    [self.window makeKeyAndVisible];
    [router presenMain];
    
//    [self setLogLevels];
//
//    // Add background and banner view to window to show in lateral transitions
//    UIImageView *imageView;
//    UIView *bannerView;
//    if (isiPhone5) {
//        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//        bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 518, 320, 50)];
//    } else {
//        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//        bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 430, 320, 50)];
//    }
//    [bannerView setBackgroundColor:[UIColor blackColor]];
//    [imageView setImage:[UIImage imageNamed:@"Background_image"]];
//    [self.window addSubview:imageView];
//    [self.window addSubview:bannerView];
//    [self.window layoutIfNeeded];
    
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

/*
 func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
 
 if let navigationController = self.window?.rootViewController as? UINavigationController {
 if navigationController.visibleViewController is ViewerViewController || navigationController.visibleViewController is VideosViewController {
 return UIInterfaceOrientationMask.all
 } else {
 return UIInterfaceOrientationMask.portrait
 }
 }
 
 return UIInterfaceOrientationMask.portrait
 }
 */

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([self handleFacebookUrl:url]) {
        
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

#pragma mark - Private methods

/**
 *  Checks if given callback URL responds to Facebook callback
 *  @return YES if callback URL responds to Facebook callback, NO otherwise
 */
- (bool)handleFacebookUrl:(NSURL *)callbackUrl
{
    return false;
    // TODO: uncoment
    //return [FBSession.activeSession handleOpenURL:callbackUrl];
}

- (bool)isUrlFromTwitterLogin:(NSURL *)url
{
    return ([[url scheme] rangeOfString:@"mobioakflip"].location != NSNotFound);
}

@end
