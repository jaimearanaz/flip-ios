//
//  FLPViewController.m
//  Flip
//
//  Created by Jaime on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <PFTwitterSignOn/PFTwitterSignOn.h>
#import <FacebookSDK/FacebookSDK.h>

#import "FLPMainScrenViewController.h"
#import "FLPPhotoSource.h"
#import "FLPCameraPhotoSource.h"
#import "FLPFacebookPhotoSource.h"
#import "FLPTwitterPhotoSource.h"
#import "FLPGridViewController.h"

#import "MBProgressHUD.h"
#import "WCAlertView.h"
#import "SCNetworkReachability.h"
#import "GADBannerView.h"

@interface FLPMainScrenViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) __block IBOutlet UIView *selectSourceView;
@property (nonatomic, weak) __block IBOutlet UIView *selectSizeView;
@property (nonatomic, weak) IBOutlet UILabel *selectSourceLbl;
@property (nonatomic, weak) IBOutlet UILabel *selectGridLbl;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property (nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property (nonatomic, weak) IBOutlet UIButton *recordsBtn;
@property (nonatomic, weak) IBOutlet UIButton *smallBtn;
@property (nonatomic, weak) IBOutlet UIButton *normalBtn;
@property (nonatomic, weak) IBOutlet UIButton *bigBtn;
@property (nonatomic, weak) IBOutlet UIButton *sourceBtn;
@property (nonatomic, weak) IBOutlet UIView *bannerView;
@property (nonatomic, strong) __block NSArray *photos;
@property (nonatomic, strong) __block FLPPhotoSource *photoSource;
@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, strong) __block twitterAccountCallback twitterCallback;
@property (nonatomic) __block SCNetworkStatus networkStatus;
@property (nonatomic, strong) NSArray *changeViewsConstraints;
@property (nonatomic) GridSizeType size;

- (IBAction)onCameraButtonPressed:(id)sender;
- (IBAction)onFacebookButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;
- (IBAction)onSmallButtonPressed:(id)sender;
- (IBAction)onNormalButtonPressed:(id)sender;
- (IBAction)onBigButtonPressed:(id)sender;
- (IBAction)onRecordsButtonPressed:(id)sender;
- (IBAction)onSourceButtonPressed:(id)sender;

@end

@implementation FLPMainScrenViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _selectSourceLbl.text = NSLocalizedString(@"MAIN_SELECT_SOURCE", @"");
    _selectGridLbl.text = NSLocalizedString(@"MAIN_SELECT_GRID", @"");
    [_cameraBtn setTitle:NSLocalizedString(@"MAIN_CAMERA", @"") forState:UIControlStateNormal];
    [_recordsBtn setTitle:NSLocalizedString(@"MAIN_RECORDS", @"") forState:UIControlStateNormal];
    [_smallBtn setTitle:NSLocalizedString(@"MAIN_SMALL", @"") forState:UIControlStateNormal];
    [_normalBtn setTitle:NSLocalizedString(@"MAIN_NORMAL", @"") forState:UIControlStateNormal];
    [_bigBtn setTitle:NSLocalizedString(@"MAIN_BIG", @"") forState:UIControlStateNormal];
    [_sourceBtn setTitle:NSLocalizedString(@"MAIN_SOURCE", @"") forState:UIControlStateNormal];
    
    // Check internet connection
    [SCNetworkReachability host:@"www.google.es" reachabilityStatus:^(SCNetworkStatus status)
     {
         // Set Internet status
         _networkStatus = status;
     }];
    
    // Banner
    GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    banner.adUnitID = kAddMobID;
    banner.rootViewController = self;
    [_bannerView addSubview:banner];
    [banner loadRequest:[GADRequest request]];
    
    _changeViewsConstraints = [[NSArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gridSegue"]) {
        FLPGridViewController *gridViewController=(FLPGridViewController *)segue.destinationViewController;
        gridViewController.photos = _photos;
        gridViewController.gridSize = _size;
    }
}

#pragma mark - IBAction methods

- (IBAction)onCameraButtonPressed:(id)sender
{
    FLPLogDebug(@"camera button pressed");
    _photoSource = [[FLPCameraPhotoSource alloc] init];
    [self checkReachabilityAndPreparePhotos];
}

- (IBAction)onFacebookButtonPressed:(id)sender
{
    FLPLogDebug(@"Facebook button pressed");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self disableButtons];
    
    [FBSession openActiveSessionWithReadPermissions:kFacebookPermissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
                                      [self enableButtons];
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      
                                      if (state == FBSessionStateOpen) {
                                          FLPLogDebug(@"Facebook session opened");
                                          _photoSource = [[FLPFacebookPhotoSource alloc] init];
                                          [FBSession setActiveSession:session];
                                          [self checkReachabilityAndPreparePhotos];
                                          
                                          
                                      } else if (state == FBSessionStateClosed || state==FBSessionStateClosedLoginFailed) {
                                          FLPLogDebug(@"Facebook session closed or failed");
                                      }
                                      
                                      if (error) {
                                          FLPLogDebug(@"Facebook session error: %@", [error localizedDescription]);
                                      }
                                  }];
}

- (IBAction)onTwitterButtonPressed:(id)sender
{
    FLPLogDebug(@"Twitter button pressed");

    [self subscribeToTwitterNotifications];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self disableButtons];
    
    // Twitter keys are stored in a plist file, not tracked in git repository
    NSString *twitterPlist = [[NSBundle mainBundle] pathForResource:@"TwitterKeys" ofType:@"plist"];
    NSDictionary *twitterKeys = [[NSDictionary alloc] initWithContentsOfFile:twitterPlist];

    [PFTwitterSignOn setCredentialsWithConsumerKey:[twitterKeys objectForKey:@"consumerKey"]
                                         andSecret:[twitterKeys objectForKey:@"secretKey"]];
    
    // Login with Twitter
    // Two ways to login:
    // a) with user account in device, through the selectCallback in this method
    // b) with Twitter login web view, through |application:openURL:sourceApplication:annotation:| method in app delegate

    [PFTwitterSignOn requestAuthenticationWithSelectCallback:^(NSArray *accounts, twitterAccountCallback callback) {
        FLPLogDebug(@"more than one Twitter account");
        
        // User has Twitter accounts on device, use action sheet
        
        // Get Twitter account names
        _twitterAccounts = accounts;
        NSMutableArray *accountNames = [[accounts valueForKey:@"username"] mutableCopy];
        [accountNames enumerateObjectsUsingBlock:^(NSString *accountName, NSUInteger index, BOOL *stop){
            [accountNames replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"@%@",accountName]];
        }];
        
        // Build and configure action sheet
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"MAIN_SELECT_TWITTER", @"")
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        for (NSString *title in accountNames) {
            [actionSheet addButtonWithTitle:title];
        }
        [actionSheet addButtonWithTitle:NSLocalizedString(@"OTHER_CANCEL", @"")];
        [actionSheet setCancelButtonIndex:accountNames.count];
        
        // Callback when user selects an option
        _twitterCallback = callback;
        
        [actionSheet showInView:self.view];
        
    } andCompletion:^(NSDictionary *accountInfo, NSError *error) {

        // Logged via web or via local account, at this point we have NSDictionary with user data
        FLPLogDebug(@"login with Twitter successful");
        
        [self unsubscribeToTwitterNotifications];
        
        _photoSource = [[FLPTwitterPhotoSource alloc] initWithOAuthConsumerKey:[twitterKeys objectForKey:@"consumerKey"]
                                                                consumerSecret:[twitterKeys objectForKey:@"secretKey"]
                                                                    oauthToken:accountInfo[@"accessToken"]
                                                              oauthTokenSecret:accountInfo[@"tokenSecret"]
                                                                     screeName:accountInfo[@"screen_name"]];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self checkReachabilityAndPreparePhotos];
    }];
}

- (IBAction)onRecordsButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    [self performSegueWithIdentifier:@"recordFromMainSegue" sender:self];
}

- (IBAction)onSmallButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    _size = GridSizeSmall;
    [self performSegueWithIdentifier:@"gridSegue" sender:self];
}

- (IBAction)onNormalButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    _size = GridSizeNormal;
    [self performSegueWithIdentifier:@"gridSegue" sender:self];
}

- (IBAction)onBigButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    _size = GridSizeBig;
    [self performSegueWithIdentifier:@"gridSegue" sender:self];
}

- (IBAction)onSourceButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    // Change to select source view
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view removeConstraints:_changeViewsConstraints];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
}

# pragma mark - UIActionSheetDelegate methods

/**
 *  Called when user selects a Twitter account or cancels action sheet
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        FLPLogDebug(@"Twitter account selected");
        _twitterCallback([_twitterAccounts objectAtIndex:buttonIndex]);
    } else {
        [self enableButtons];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

#pragma mark - Custom methods

- (void)enableButtons
{
    _cameraBtn.enabled = YES;
    _facebookBtn.enabled = YES;
    _twitterBtn.enabled = YES;
}

- (void)disableButtons
{
    _cameraBtn.enabled = NO;
    _facebookBtn.enabled = NO;
    _twitterBtn.enabled = NO;
}

/**
 * Checks internet connection and prepares photos from source
 */
- (void)checkReachabilityAndPreparePhotos
{
    // Check internet connection
    [SCNetworkReachability host:@"www.google.es" reachabilityStatus:^(SCNetworkStatus status)
     {
         // Internet status is known, prepare photos
         _networkStatus = status;
         [self preparePhotos];
     }];
}

/**
 * Prepares photos from source and runs segue to next view controller.
 * Photos may be downloaded from source or loaded from cache, depending on network status and the photo source
 */
- (void)preparePhotos
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self disableButtons];
    
    // Declare block to execute when getting photos is successful
    // Runs segue to next view controller
    void (^successBlock)(NSArray *);
    successBlock = ^(NSArray *photos) {
        FLPLogDebug(@"success");
        [self enableButtons];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _photos = photos;
        if ((_photos != nil) && (photos.count != 0)) {

            // Change to select size view
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self.view removeConstraints:_changeViewsConstraints];
                                 UIView *selectSourceView = self.selectSourceView;
                                 NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(selectSourceView);
                                 _changeViewsConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[selectSourceView]-640-|"
                                                                                                   options:0
                                                                                                   metrics:nil
                                                                                                     views:viewsDictionary];
                                 [self.view addConstraints:_changeViewsConstraints];
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                             }];

            //[self performSegueWithIdentifier:@"sizeSegue" sender:self];
        }
    };
    
    // Declare block to execute when getting photos fails
    void (^failureBlock)(NSError *);
    failureBlock = ^(NSError *error) {
        FLPLogDebug(@"failure");
        [self enableButtons];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error.code == KErrorEnoughPhotos) {
            NSString *message = [self customNoPhotosMessageForSource:_photoSource];
            [WCAlertView showAlertWithTitle:NSLocalizedString(@"MAIN_ALERT", nil)
                                    message:message
                         customizationBlock:nil
                            completionBlock:nil
                          cancelButtonTitle:NSLocalizedString(@"OTHER_OK", nil)
                          otherButtonTitles:nil];
        } else {
            [WCAlertView showAlertWithTitle:NSLocalizedString(@"MAIN_ALERT", nil)
                                    message:NSLocalizedString(@"MAIN_GENERIC_ERROR", nil)
                         customizationBlock:nil
                            completionBlock:nil
                          cancelButtonTitle:NSLocalizedString(@"OTHER_OK", nil)
                          otherButtonTitles:nil];
        }
        

    };

    
    if (_photoSource) {
        
        // Source needs an internet connection
        if ([_photoSource internetRequired]) {
            FLPLogDebug(@"internet connection is needed");
            
            // No internet available, try to use cache
            if (_networkStatus == SCNetworkStatusNotReachable) {
                FLPLogDebug(@"no internet connection");
                
                if ([_photoSource hasPhotosInCache]) {
                    FLPLogDebug(@"load photos from cache");
                    [_photoSource getPhotosFromCacheFinishBlock:^(NSArray *photos) {
                        successBlock(photos);
                    }];
                } else {
                    FLPLogDebug(@"no cache available");
                    [self enableButtons];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [WCAlertView showAlertWithTitle:NSLocalizedString(@"MAIN_ALERT", nil)
                                            message:NSLocalizedString(@"MAIN_INERNET_CONNECTION", nil)
                                 customizationBlock:nil
                                    completionBlock:nil
                                  cancelButtonTitle:NSLocalizedString(@"OTHER_OK", nil)
                                  otherButtonTitles:nil];
                }
                
            // WiFi connection available, download photos from source and save them to cache
            } else if (_networkStatus == SCNetworkStatusReachableViaWiFi) {
                FLPLogDebug(@"internet connection via WiFi");
                
                [_photoSource deleteCache];
                [_photoSource getPhotosFromSource:kMinimunPhotos
                                      succesBlock:^(NSArray *photos) {
                                          [_photoSource savePhotosToCache:photos];
                                          successBlock(photos);
                                      }
                                     failureBlock:^(NSError *error) {
                                         failureBlock(error);
                                     }];
                
            // Cellular connection available, try to use cache or download photos from source
            } else if (_networkStatus == SCNetworkStatusReachableViaCellular) {
                FLPLogDebug(@"internet connection via cellular");
                
                if ([_photoSource hasPhotosInCache]) {
                    FLPLogDebug(@"load photos from cache");
                    [_photoSource getPhotosFromCacheFinishBlock:^(NSArray *photos) {
                        successBlock(photos);
                    }];
                } else {
                    FLPLogDebug(@"download photos from source");
                    [_photoSource deleteCache];
                    [_photoSource getPhotosFromSource:kMinimunPhotos
                                          succesBlock:^(NSArray *photos) {
                                              [_photoSource savePhotosToCache:photos];
                                              successBlock(photos);
                                          }
                                         failureBlock:^(NSError *error) {
                                             failureBlock(error);
                                         }];
                }
            }
            
        // Source doesn't need an internet connection
        } else {
            FLPLogDebug(@"no internet connection is needed");
            [_photoSource getPhotosFromSource:kMinimunPhotos
                                  succesBlock:^(NSArray *photos) {
                                      successBlock(photos);
                                  }
                                 failureBlock:^(NSError *error) {
                                    failureBlock(error);
                                 }];
        }
    } else {
        FLPLogError(@"No photo source configured!");
    }
}

/**
 *  Customizes the error message where there is not enough photos in the selected source
 *  @param photoSource Source where the photos are located
 *  @return Customized error message
 */
- (NSString *)customNoPhotosMessageForSource:(FLPPhotoSource *)photoSource
{
    NSString *message = nil;
    
    // Camera
    if ([photoSource isKindOfClass:[FLPCameraPhotoSource class]]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"MAIN_ENOUGH_PHOTOS_CAMERA", nil), kMinimunPhotos];
        
    // Twitter
    } else if ([photoSource isKindOfClass:[FLPTwitterPhotoSource class]]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"MAIN_ENOUGH_PHOTOS_TWITTER", nil), kMinimunPhotos];

    // Other source
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"MAIN_ENOUGH_PHOTOS_OTHER", nil), kMinimunPhotos];
    }
    
    return message;
}

- (void)twitterLoginCanceledNotification
{
    [self enableButtons];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self unsubscribeToTwitterNotifications];
}

- (void)subscribeToTwitterNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(twitterLoginCanceledNotification)
                                                 name:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION
                                               object:nil];
}

- (void)unsubscribeToTwitterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION
                                                  object:nil];
}

@end
