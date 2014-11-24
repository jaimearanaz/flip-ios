//
//  FLPViewController.m
//  Flip
//
//  Created by Jaime Aranaz on 14/07/14.
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

// Types of sources available
typedef enum {
    PhotoSourceCamera,
    PhotoSourceFacebook,
    PhotoShourceTwitter
} PhotoSourceType;

@interface FLPMainScrenViewController () <UIActionSheetDelegate>

// Main view elements
@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLbl;
@property (nonatomic, strong) UIView *stripView;
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

// Constraints used to animate between main views
@property (nonatomic, strong) NSArray *showRecordsViewConstraints;
@property (nonatomic, strong) NSArray *showSourceViewConstraints;
@property (nonatomic, strong) NSArray *showSizeViewConstraints;
@property (nonatomic, strong) NSArray *currentViewConstraints;

// Photos to use in grid
@property (nonatomic, strong) __block NSArray *photos;
// Source of photos
@property (nonatomic, strong) __block FLPPhotoSource *photoSource;
// List of Twitter accounts configured in device
@property (nonatomic, strong) NSArray *twitterAccounts;
// Callback used when login with Twitter API
@property (nonatomic, strong) __block twitterAccountCallback twitterCallback;
// Status of network connection
@property (nonatomic) __block SCNetworkStatus networkStatus;
// Size selected for grid
@property (nonatomic) GridSizeType size;
// Type of photo source
@property (nonatomic) PhotoSourceType source;
// Timer used to animate header logo
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


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    FLPLogDebug(@"traitCollectionDidChange");
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    FLPLogDebug(@"viewWillTransitionToSize");
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    FLPLogDebug(@"willTransitionToTraitCollection");
}

- (NSUInteger)supportedInterfaceOrientations
{
    // Only iPad and iPhone 6 Plus must rotate
    
    // iPhone 6 Plus should be detected using size class, not height!
    // But on simulator, iPhone 6 Plus in landscape is still compact!!
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat height = screen.bounds.size.height;
    
    // It's an iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        return UIInterfaceOrientationMaskAll;
    // It's an iPhone 6 Plus
    } else if (height == 736) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    // It's other iPhone
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    FLPLogDebug(@"updateViewConstraints");
    
    if (self.stripView) {
        [self.stripView removeFromSuperview];
    }
    
    // First, configure strip view, where buttons views are allocated
    
    self.stripView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.stripView.backgroundColor = [UIColor blueColor];
    self.stripView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.stripView];
    
    // Views used in constraints
    UIView *recordsView = self.recordsView;
    UIView *selectSourceView = self.selectSourceView;
    UIView *selectSizeView = self.selectSizeView;
    UIView *stripView = self.stripView;
    UIView *titleView = self.titleView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(titleView,
                                                                   stripView,
                                                                   recordsView,
                                                                   selectSourceView,
                                                                   selectSizeView);
    
    // top space constraint from title
    NSArray *topConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleView]-10-[stripView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary];
    // height fixed constraint
    NSArray *heightConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[stripView(200)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    // witdh constraint depending on screen width
    NSNumber *width = [NSNumber numberWithFloat:(self.view.bounds.size.width + 320 + 320)];
    NSArray *widthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[stripView(width)]"
                                                                       options:0
                                                                       metrics:@{@"width": width}
                                                                         views:viewsDictionary];
    // leading space constraint of -320
    NSNumber *leading = [NSNumber numberWithFloat:(320 * -1)];
    NSArray *leadingConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leading)-[stripView]"
                                                                         options:0
                                                                         metrics:@{@"leading": leading}
                                                                           views:viewsDictionary];

    [self.view addConstraints:topConstraint];
    [self.view addConstraints:heightConstraint];
    [self.view addConstraints:widthConstraint];
    [self.view addConstraints:leadingConstraint];
    
    // Second, configure views inside strip view
    
    [self.recordsView removeFromSuperview];
    [self.selectSourceView removeFromSuperview];
    [self.selectSizeView removeFromSuperview];
    
    [self.stripView addSubview:self.recordsView];
    [self.stripView addSubview:self.selectSourceView];
    [self.stripView addSubview:self.selectSizeView];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    NSNumber *offset = [NSNumber numberWithFloat:(screenWidth - 320) / 2];
    
    // horizontal space between views
    NSString *constraintFormat = @"H:|-0-[recordsView]-offset-[selectSourceView]-offset-[selectSizeView]-0-|";
    
    NSArray *spacingConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintFormat
                                                                          options:0
                                                                          metrics:@{@"offset": offset}
                                                                            views:viewsDictionary];
    
    // center vertical constraint for source view
    NSLayoutConstraint *centerSourceYConstraint = [NSLayoutConstraint constraintWithItem:self.selectSourceView
                                                                               attribute:NSLayoutAttributeCenterY
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.stripView
                                                                               attribute:NSLayoutAttributeCenterY
                                                                              multiplier:1.0
                                                                                constant:0.0];
    // center vertical constraint for records view
    NSLayoutConstraint *centerRecordsYConstraint = [NSLayoutConstraint constraintWithItem:self.recordsView
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.stripView
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0
                                                                                 constant:0.0];
    // center vertical constraint for size view
    NSLayoutConstraint *centerSizeYConstraint = [NSLayoutConstraint constraintWithItem:self.selectSizeView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.stripView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.0
                                                                              constant:0.0];
    
    [self.stripView addConstraints:spacingConstraints];
    [self.stripView addConstraint:centerRecordsYConstraint];
    [self.stripView addConstraint:centerSourceYConstraint];
    [self.stripView addConstraint:centerSizeYConstraint];
    
}

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
    
    // Configure constraints to change between records, source and size view
    
    /*
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
     */
    /*
    // Start controller showing records view
    if (_startWithRecordsView) {
        _currentViewConstraints = _showRecordsViewConstraints;
        
    // Start controller showing source view
    } else {
        // Hide records view to avoid ugly effect when comes from score screen
        self.recordsView.hidden = YES;
        
        [self.view addConstraints:_showSourceViewConstraints];
        _currentViewConstraints = _showSourceViewConstraints;
    }
    */
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
    _source = PhotoSourceCamera;
    [self showSizeView];
}

- (IBAction)onFacebookButtonPressed:(id)sender
{
    _source = PhotoSourceFacebook;
    [self showSizeView];
}

- (IBAction)onTwitterButtonPressed:(id)sender
{
    _source = PhotoShourceTwitter;
    [self showSizeView];
}

- (IBAction)onRecordsButtonPressed:(id)sender
{
    [self showRecordsView];
}

- (IBAction)onSmallButtonPressed:(id)sender
{
    _size = GridSizeSmall;
    [self checkReachabilityAndPreparePhotos];
    
}

- (IBAction)onMediumButtonPressed:(id)sender
{
    _size = GridSizeMedium;
    [self checkReachabilityAndPreparePhotos];
}

- (IBAction)onBigButtonPressed:(id)sender
{
    _size = GridSizeBig;
    [self checkReachabilityAndPreparePhotos];
}

- (IBAction)onSourceButtonPressed:(id)sender
{
    [self showSourceView];
}

- (IBAction)onStartGameButtonPressed:(id)sender
{
    [self showSourceView];
}

#pragma mark - UIActionSheetDelegate methods

/**
 *  Called when user selects a Twitter account or cancels action sheet
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        _twitterCallback([_twitterAccounts objectAtIndex:buttonIndex]);
    } else {
        [self enableButtons];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

#pragma mark - Private methods

/**
 * Enables size view buttons
 */
- (void)enableButtons
{
    _smallBtn.enabled = YES;
    _mediumBtn.enabled = YES;
    _bigBtn.enabled = YES;
    _sourceBtn.enabled = YES;
}

/**
 * Disables size view buttons
 */
- (void)disableButtons
{
    _smallBtn.enabled = NO;
    _mediumBtn.enabled = NO;
    _bigBtn.enabled = NO;
    _sourceBtn.enabled = NO;
}

/**
 * Animates to show size view
 */
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

/**
 * Animates to show source view
 */
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

/**
 * Animates to show records view
 */
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

/**
 * Starts timer to animate header with logo
 */
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

/**
 * Ends timer used to animate header with logo
 */
- (void)endTimer
{
    if (_timerTitle != nil) {
        [_timerTitle invalidate];
        _timerTitle = nil;
    }
}

/**
 * Flips a letter in header logo randomly. Fired by a timer.
 */
- (void)flipRandomLetter
{
    NSInteger random = (arc4random() % 4);
    UIView *letter = [_titleView.subviews objectAtIndex:random];
    
    if ([letter isKindOfClass:[FLPTitleLetterView class]]){
        [letter performSelector:@selector(flipAnimated:) withObject:[NSNumber numberWithBool:YES]];
    }
}

/**
 * Checks internet connection and prepares photos from source
 * The complete process steps are:
 * 1. user selects source (done at this point)
 * 2. user selects grid size (done at this point)
 * 3. network connection is checked (here)
 * 4. photo source object is configured (here)
 * 5. photos are get form origin or cache, depending on network and source (method |preparePhotos|)
 * 6. next view controller to start game
 */
- (void)checkReachabilityAndPreparePhotos
{
    // Check internet connection
    [SCNetworkReachability host:@"www.google.es" reachabilityStatus:^(SCNetworkStatus status)
     {
         FLPLogWarn(@"network status %ld", (long)status);
         // Internet status is known, prepare photos
         _networkStatus = status;
         
         switch (_source) {
             case PhotoSourceCamera:
                 _photoSource = [[FLPCameraPhotoSource alloc] init];
                 break;
             case PhotoSourceFacebook:
                 _photoSource = [[FLPFacebookPhotoSource alloc] init];
                 break;
             case PhotoShourceTwitter:
                 _photoSource = [[FLPTwitterPhotoSource alloc] init];
                 break;
             default:
                 _photoSource = nil;
                 break;
         }
         
         [self preparePhotos];
     }];
}

/**
 * Starts getting photos process from Facebook source
 */
- (void)loginInFacebookAndPreparePhotosOnSuccess:(void(^)())success onFail:(void(^)(NSError *error))fail
{
    BOOL openedWithCachedToken = [FBSession openActiveSessionWithAllowLoginUI:NO];
    FLPLogDebug(@"Facebook cached token %d", openedWithCachedToken);
    
    // Facebook session is open
    if (openedWithCachedToken) {
                _photoSource = [[FLPFacebookPhotoSource alloc] init];
                success();

    // No Facebook session, login
    } else {
        [FBSession openActiveSessionWithReadPermissions:kFacebookPermissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
                                          if (state == FBSessionStateOpen) {
                                              FLPLogWarn(@"Facebook session opened");
                                              _photoSource = [[FLPFacebookPhotoSource alloc] init];
                                              [FBSession setActiveSession:session];
                                              
                                              success();
                                              
                                          } else if (state == FBSessionStateClosed || state==FBSessionStateClosedLoginFailed) {
                                              FLPLogWarn(@"Facebook session closed or failed");
                                          }
                                          
                                          if (error) {
                                              FLPLogError(@"Facebook session error: %@", [error localizedDescription]);
                                              fail([NSError errorWithDomain:@""
                                                                       code:KErrorLogin
                                                                   userInfo:nil]);
                                          }
                                      }];
    }
}

/**
 * Starts getting photos process from Twitter source
 */
- (void)loginInTwitterAndPreparePhotosOnSuccess:(void(^)())success onFail:(void(^)(NSError *error))fail
{
    [self subscribeToTwitterNotifications];
    
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
        FLPLogWarn(@"more than one Twitter account");
        
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
        
        if (error) {
            FLPLogError(@"error: %@", [error localizedDescription]);
            fail([NSError errorWithDomain:@""
                                     code:KErrorLogin
                                 userInfo:nil]);
        } else {
            FLPLogWarn(@"login with Twitter successful");
        
            // Logged via web or via local account, at this point we have NSDictionary with user data

            [self unsubscribeToTwitterNotifications];
            
            [(FLPTwitterPhotoSource *)_photoSource setOauthConsumerKey:[twitterKeys objectForKey:@"consumerKey"]
                                                        consumerSecret:[twitterKeys objectForKey:@"secretKey"]
                                                            oauthToken:accountInfo[@"accessToken"]
                                                      oauthTokenSecret:accountInfo[@"tokenSecret"]
                                                             screeName:accountInfo[@"screen_name"]];
            
            success();
        }
    }];
}

- (void)loginInPhotoSourceAndPreparePhotosOnSuccess:(void(^)())success onFail:(void(^)(NSError *error))fail
{
    // Login in Facebook and get photos
    if ([_photoSource isKindOfClass:[FLPFacebookPhotoSource class]]) {
        [self loginInFacebookAndPreparePhotosOnSuccess:success onFail:fail];
        
    // Login in Twitter and get photos
    } else if ([_photoSource isKindOfClass:[FLPTwitterPhotoSource class]]) {
        [self loginInTwitterAndPreparePhotosOnSuccess:success onFail:fail];
    }
}

/**
 * Prepares photos from source and then runs segue to next view controller.
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
    // Shows error message
    void (^failureBlock)(NSError *);
    failureBlock = ^(NSError *error) {
        FLPLogError(@"failure %@", [error localizedDescription]);
        [self enableButtons];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showSourceView];
        
        // Show error message
        
        if (error.code == KErrorEnoughPhotos) {
            NSString *message = [self customNoPhotosMessageForSource:_photoSource];
            [WCAlertView showAlertWithTitle:NSLocalizedString(@"MAIN_ALERT", nil)
                                    message:message
                         customizationBlock:nil
                            completionBlock:nil
                          cancelButtonTitle:NSLocalizedString(@"OTHER_OK", nil)
                          otherButtonTitles:nil];
        } else if (error.code == KErrorLogin) {
            NSString *message = [self customLoginErrorForSource:_photoSource];
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
                    FLPLogWarn(@"desconnected, load photos from cache");
                    [_photoSource getPhotosFromCacheFinishBlock:^(NSArray *photos) {
                        successBlock(photos);
                    }];
                } else {
                    FLPLogWarn(@"desconnected, no cache available");
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
                FLPLogWarn(@"internet connection via WiFi");

                // Login in photo source and go on
                [self loginInPhotoSourceAndPreparePhotosOnSuccess:^{
                    [_photoSource deleteCache];
                    [_photoSource getPhotosFromSource:kMinimunPhotos
                                          succesBlock:^(NSArray *photos) {
                                              [_photoSource savePhotosToCache:photos];
                                              successBlock(photos);
                                          }
                                         failureBlock:^(NSError *error) {
                                             failureBlock(error);
                                         }];
                } onFail:^(NSError *error){
                    failureBlock(error);
                }];
                
                
                
            // Cellular connection available, try to use cache or download photos from source
            } else if (_networkStatus == SCNetworkStatusReachableViaCellular) {
                FLPLogDebug(@"internet connection via cellular");
                
                if ([_photoSource hasPhotosInCache]) {
                    FLPLogWarn(@"cellular, load photos from cache");
                    [_photoSource getPhotosFromCacheFinishBlock:^(NSArray *photos) {
                        successBlock(photos);
                    }];
                } else {
                    FLPLogWarn(@"cellular, download photos from source");
                    
                    // Login in photo source and go on
                    [self loginInPhotoSourceAndPreparePhotosOnSuccess:^{
                        [_photoSource deleteCache];
                        [_photoSource getPhotosFromSource:kMinimunPhotos
                                              succesBlock:^(NSArray *photos) {
                                                  [_photoSource savePhotosToCache:photos];
                                                  successBlock(photos);
                                              }
                                             failureBlock:^(NSError *error) {
                                                 failureBlock(error);
                                             }];
                    } onFail:^(NSError *error){
                        failureBlock(error);
                    }];
                }
            }
            
        // Source doesn't need an internet connection
        } else {
            FLPLogWarn(@"no internet connection is needed");
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
 *  Customizes the error message when there is not enough photos in the selected source
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

/**
 *  Customizes the error message when the login process fails for a photo source
 *  @param photoSource Source where the login was failed
 *  @return Customized error message
 */
- (NSString *)customLoginErrorForSource:(FLPPhotoSource *)photoSource
{
    NSString *message = nil;
    
    // Facebook
    if ([photoSource isKindOfClass:[FLPFacebookPhotoSource class]]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"MAIN_LOGIN_ERROR_FACEBOOK", nil)];
        
    // Twitter
    }else if ([photoSource isKindOfClass:[FLPTwitterPhotoSource class]]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"MAIN_LOGIN_ERROR_TWITTER", nil)];
    }
    
    return message;
}

/**
 * Called when users cancels Twitter web login
 */
- (void)twitterLoginCanceledNotification
{
    [self enableButtons];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self showSourceView];
    [self unsubscribeToTwitterNotifications];
    
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"MAIN_ALERT", nil)
                            message:NSLocalizedString(@"MAIN_LOGIN_ERROR_TWITTER", nil)
                 customizationBlock:nil
                    completionBlock:nil
                  cancelButtonTitle:NSLocalizedString(@"OTHER_OK", nil)
                  otherButtonTitles:nil];
}

/**
 * Subscribes to Twitter cancel notification, to know if users cancels Twitter web login
 */
- (void)subscribeToTwitterNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(twitterLoginCanceledNotification)
                                                 name:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION
                                               object:nil];
}

/**
 * Unsubscribes to Twitter cancel notification
 */
- (void)unsubscribeToTwitterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION
                                                  object:nil];
}

@end
