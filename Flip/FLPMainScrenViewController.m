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
#import "FLPTitleLetterView.h"

#import "MBProgressHUD.h"
#import "WCAlertView.h"
#import "SCNetworkReachability.h"
#import "GADBannerView.h"

typedef enum {
    PhotoSourceCamera,
    PhotoSourceFacebook,
    PhotoShourceTwitter
} PhotoSourceType;

@interface FLPMainScrenViewController () <UIActionSheetDelegate>

// Main elements
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLbl;
@property (nonatomic, weak) IBOutlet UIView *stripView;
@property (nonatomic, weak) __block IBOutlet UIView *selectSourceView;
@property (nonatomic, weak) __block IBOutlet UIView *selectSizeView;
@property (nonatomic, weak) __block IBOutlet UIView *recordsView;

// Records view elements
@property (nonatomic, weak) IBOutlet UILabel *recordsLbl;
@property (nonatomic, weak) IBOutlet UILabel *smallLbl;
@property (nonatomic, weak) IBOutlet UILabel *smallRecordLbl;
@property (nonatomic, weak) IBOutlet UILabel *mediumLbl;
@property (nonatomic, weak) IBOutlet UILabel *mediumRecordLbl;
@property (nonatomic, weak) IBOutlet UILabel *bigLbl;
@property (nonatomic, weak) IBOutlet UILabel *bigRecordLbl;
@property (nonatomic, weak) IBOutlet UIButton *startGameBtn;

// Source view elements
@property (nonatomic, weak) IBOutlet UILabel *selectSourceLbl;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property (nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property (nonatomic, weak) IBOutlet UIButton *recordsBtn;

// Size view elements
@property (nonatomic, weak) IBOutlet UILabel *selectGridLbl;
@property (nonatomic, weak) IBOutlet UIButton *smallBtn;
@property (nonatomic, weak) IBOutlet UILabel *smallButtonLbl;
@property (nonatomic, weak) IBOutlet UIButton *mediumBtn;
@property (nonatomic, weak) IBOutlet UILabel *mediumButtonLbl;
@property (nonatomic, weak) IBOutlet UIButton *bigBtn;
@property (nonatomic, weak) IBOutlet UILabel *bigButtonLbl;
@property (nonatomic, weak) IBOutlet UIButton *sourceBtn;

@property (nonatomic, weak) IBOutlet UIView *bannerView;

@property (nonatomic, strong) __block NSArray *photos;
@property (nonatomic, strong) __block FLPPhotoSource *photoSource;
@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, strong) __block twitterAccountCallback twitterCallback;
@property (nonatomic) __block SCNetworkStatus networkStatus;

@property (nonatomic, strong) NSArray *showRecordsViewConstraints;
@property (nonatomic, strong) NSArray *showSourceViewConstraints;
@property (nonatomic, strong) NSArray *showSizeViewConstraints;
@property (nonatomic, strong) NSArray *currentViewConstraints;

@property (nonatomic) GridSizeType size;
@property (nonatomic) PhotoSourceType source;
@property (nonatomic, strong) NSTimer *timerTitle;

- (IBAction)onCameraButtonPressed:(id)sender;
- (IBAction)onFacebookButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;
- (IBAction)onSmallButtonPressed:(id)sender;
- (IBAction)onMediumButtonPressed:(id)sender;
- (IBAction)onBigButtonPressed:(id)sender;
- (IBAction)onRecordsButtonPressed:(id)sender;
- (IBAction)onSourceButtonPressed:(id)sender;
- (IBAction)onStartGameButtonPressed:(id)sender;

@end

@implementation FLPMainScrenViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [_subtitleLbl setFont:[UIFont fontWithName:@"Pacifico" size:25]];
    
    // Records view
    
    [_recordsLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:20]];
    _recordsLbl.text = NSLocalizedString(@"MAIN_RECORDS_TITLE", @"");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *recordSmall = (NSDate *)[userDefaults objectForKey:@"small"];
    NSDate *recordNormal = (NSDate *)[userDefaults objectForKey:@"normal"];
    NSDate *recordBig = (NSDate *)[userDefaults objectForKey:@"big"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss:SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    [_smallLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _smallLbl.text = NSLocalizedString(@"MAIN_SMALL", @"");
    [_smallRecordLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _smallRecordLbl.text = (recordSmall) ? [dateFormatter stringFromDate:recordSmall] : NSLocalizedString(@"MAIN_RECORDS_NONE", @"");
    
    [_mediumLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _mediumLbl.text = NSLocalizedString(@"MAIN_MEDIUM", @"");
    [_mediumRecordLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _mediumRecordLbl.text = (recordNormal) ? [dateFormatter stringFromDate:recordNormal] : NSLocalizedString(@"MAIN_RECORDS_NONE", @"");
    
    [_bigLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _bigLbl.text = NSLocalizedString(@"MAIN_BIG", @"");
    [_bigRecordLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _bigRecordLbl.text = (recordBig) ? [dateFormatter stringFromDate:recordBig] : NSLocalizedString(@"MAIN_RECORDS_NONE", @"");
    
    [_startGameBtn.titleLabel setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    [_startGameBtn setTitle:NSLocalizedString(@"MAIN_START", @"") forState:UIControlStateNormal];
    
    // Select source view
    [_selectSourceLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _selectSourceLbl.text = NSLocalizedString(@"MAIN_SELECT_SOURCE", @"");
    [_cameraBtn.titleLabel setFont:[UIFont fontWithName:@"Pacifico" size:20]];
        [_cameraBtn setTitle:NSLocalizedString(@"MAIN_CAMERA", @"") forState:UIControlStateNormal];
    [_facebookBtn.titleLabel setFont:[UIFont fontWithName:@"Pacifico" size:20]];
    [_twitterBtn.titleLabel setFont:[UIFont fontWithName:@"Pacifico" size:20]];
    [_recordsBtn.titleLabel setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    [_recordsBtn setTitle:NSLocalizedString(@"MAIN_RECORDS", @"") forState:UIControlStateNormal];
    
    // Select grid size view
    [_selectGridLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    _selectGridLbl.text = NSLocalizedString(@"MAIN_SELECT_GRID", @"");
    // Use labels because button's label don't fit well with this font
    [_smallButtonLbl setFont:[UIFont fontWithName:@"Pacifico" size:20]];
    [_smallButtonLbl setText:NSLocalizedString(@"MAIN_SMALL", @"")];
    [_mediumButtonLbl setFont:[UIFont fontWithName:@"Pacifico" size:20]];
    [_mediumButtonLbl setText:NSLocalizedString(@"MAIN_MEDIUM", @"")];
    [_bigButtonLbl setFont:[UIFont fontWithName:@"Pacifico" size:20]];
    [_bigButtonLbl setText:NSLocalizedString(@"MAIN_BIG", @"")];
    
    [_sourceBtn.titleLabel setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:17]];
    [_sourceBtn setTitle:NSLocalizedString(@"MAIN_SOURCE", @"") forState:UIControlStateNormal];
    
    // Check internet connection
    [SCNetworkReachability host:@"www.google.es" reachabilityStatus:^(SCNetworkStatus status)
     {
         // Set Internet status
         _networkStatus = status;
     }];
    
    // Configure banner
    GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // AdMob key is stored in a plist file, not tracked in git repository
    NSString *adMobPlist = [[NSBundle mainBundle] pathForResource:@"AdMobKey" ofType:@"plist"];
    NSDictionary *adMobKey = [[NSDictionary alloc] initWithContentsOfFile:adMobPlist];
    banner.adUnitID = [adMobKey objectForKey:@"key"];
    banner.rootViewController = self;
    [_bannerView addSubview:banner];
    [banner loadRequest:[GADRequest request]];
    
    // Constraints to change between records, source and size view
    
    UIView *stripView = self.stripView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(stripView);

    _showRecordsViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[stripView]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
    
    _showSourceViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(-320)-[stripView]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
    
    _showSizeViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(-640)-[stripView]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];

    // Show records view
    if (_startWithRecordsView) {
        _currentViewConstraints = _showRecordsViewConstraints;
        
    // Show source view
    } else {
        // Hide records view to avoid ugly effect when comes from score screen
        self.recordsView.hidden = YES;
        
        [self.view addConstraints:_showSourceViewConstraints];
        _currentViewConstraints = _showSourceViewConstraints;
    }
    
    [self startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self endTimer];
    
    if ([segue.identifier isEqualToString:@"gridFromMainSegue"]) {
        FLPGridViewController *gridViewController=(FLPGridViewController *)segue.destinationViewController;
        gridViewController.photos = _photos;
        gridViewController.gridSize = _size;
    }
}

#pragma mark - IBAction methods

- (IBAction)onCameraButtonPressed:(id)sender
{
    FLPLogDebug(@"camera button pressed");
    _source = PhotoSourceCamera;
    [self showSizeView];
}

- (IBAction)onFacebookButtonPressed:(id)sender
{
    FLPLogDebug(@"Facebook button pressed");
    _source = PhotoSourceFacebook;
    [self showSizeView];
}

- (IBAction)onTwitterButtonPressed:(id)sender
{
    FLPLogDebug(@"Twitter button pressed");
    _source = PhotoShourceTwitter;
    [self showSizeView];
}

- (IBAction)onRecordsButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    [self showRecordsView];
    //[self performSegueWithIdentifier:@"recordsFromMainSegue" sender:self];
}

- (IBAction)onSmallButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    _size = GridSizeSmall;
    [self preparePhotosFromSource];
    
}

- (IBAction)onMediumButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    _size = GridSizeMedium;
    [self preparePhotosFromSource];
}

- (IBAction)onBigButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    _size = GridSizeBig;
    [self preparePhotosFromSource];
}

- (IBAction)onSourceButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    [self showSourceView];
}

- (IBAction)onStartGameButtonPressed:(id)sender
{
    FLPLogDebug(@"");
    [self showSourceView];
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

#pragma mark - Private methods

- (void)enableButtons
{
    _smallBtn.enabled = YES;
    _mediumBtn.enabled = YES;
    _bigBtn.enabled = YES;
    _sourceBtn.enabled = YES;
}

- (void)disableButtons
{
    _smallBtn.enabled = NO;
    _mediumBtn.enabled = NO;
    _bigBtn.enabled = NO;
    _sourceBtn.enabled = NO;
}

- (void)showSizeView
{
    [_recordsLbl setAlpha:0];
    [_selectSourceLbl setAlpha:0];
    [_selectGridLbl setAlpha:0];
    
    // Change to select size view
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view removeConstraints:_currentViewConstraints];
                         _currentViewConstraints = _showSizeViewConstraints;
                         [self.view addConstraints:_showSizeViewConstraints];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              [_selectGridLbl setAlpha:1];
                                          }];
                     }];
}

- (void)showSourceView
{
    [_recordsLbl setAlpha:0];
    [_selectSourceLbl setAlpha:0];
    [_selectGridLbl setAlpha:0];
    
    // Change to select source view
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view removeConstraints:_currentViewConstraints];
                         _currentViewConstraints = _showSourceViewConstraints;
                         [self.view addConstraints:_showSourceViewConstraints];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              [_selectSourceLbl setAlpha:1];
                                          }];
                     }];
}

- (void)showRecordsView
{
    [_recordsLbl setAlpha:0];
    [_selectSourceLbl setAlpha:0];
    [_selectGridLbl setAlpha:0];
    
    // Records view was hidden to avoid ugly effect when comes from score screen
    self.recordsView.hidden = NO;
    
    // Change to records view
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view removeConstraints:_currentViewConstraints];
                         _currentViewConstraints = _showRecordsViewConstraints;
                         [self.view addConstraints:_showRecordsViewConstraints];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              [_recordsLbl setAlpha:1];
                                          }];
                     }];
}

- (void)startTimer
{
    if (_timerTitle == nil) {
        _timerTitle = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                       target:self
                                                     selector:@selector(flipRandomLetter)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

- (void)endTimer
{
    if (_timerTitle != nil) {
        [_timerTitle invalidate];
        _timerTitle = nil;
    }
}

- (void)flipRandomLetter
{
    NSInteger random = (arc4random() % 4);
    UIView *letter = [_titleView.subviews objectAtIndex:random];
    
    if ([letter isKindOfClass:[FLPTitleLetterView class]]){
        [letter performSelector:@selector(flipAnimated:) withObject:[NSNumber numberWithBool:YES]];
    }
}

- (void)preparePhotosFromSource
{
    switch (_source) {
        case PhotoSourceCamera:
            [self preparePhotosFromCamera];
            break;
        case PhotoSourceFacebook:
            [self preparePhotosFromFacebook];
            break;
        case PhotoShourceTwitter:
            [self preparePhotosFromTwitter];
            break;
        default:
            break;
    }
}

- (void)preparePhotosFromCamera
{
    _photoSource = [[FLPCameraPhotoSource alloc] init];
    [self checkReachabilityAndPreparePhotos];
}

- (void)preparePhotosFromFacebook
{
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

- (void)preparePhotosFromTwitter
{
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
            [self performSegueWithIdentifier:@"gridFromMainSegue" sender:self];
        }
    };
    
    // Declare block to execute when getting photos fails
    void (^failureBlock)(NSError *);
    failureBlock = ^(NSError *error) {
        FLPLogDebug(@"failure");
        [self enableButtons];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showSourceView];
        
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

    // Facebook
    } else if ([photoSource isKindOfClass:[FLPFacebookPhotoSource class]]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"MAIN_ENOUGH_PHOTOS_FACEBOOK", nil), kMinimunPhotos];

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
    [self showSourceView];
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
