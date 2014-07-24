//
//  FLPViewController.m
//  Flip
//
//  Created by Jaime on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <PFTwitterSignOn/PFTwitterSignOn.h>

#import "FLPMainScrenViewController.h"
#import "FLPCameraPhotoSource.h"
#import "FLPPhotoSource.h"
#import "FLPGridViewController.h"

#import "MBProgressHUD.h"
#import "WCAlertView.h"

@interface FLPMainScrenViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UILabel *selectLbl;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property (nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property (nonatomic, weak) IBOutlet UIButton *recordsBtn;
@property (nonatomic, strong) __block NSArray *photos;
@property (nonatomic, strong) __block FLPPhotoSource *photoSource;
@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, strong) __block twitterAccountCallback twitterCallback;

- (IBAction)onCameraButtonPressed:(id)sender;
- (IBAction)onFacebookButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;

@end

@implementation FLPMainScrenViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _selectLbl.text = NSLocalizedString(@"MAIN_SELECT", @"");
    [_cameraBtn setTitle:NSLocalizedString(@"MAIN_CAMERA", @"") forState:UIControlStateNormal];
    [_recordsBtn setTitle:NSLocalizedString(@"MAIN_RECORDS", @"") forState:UIControlStateNormal];
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
    }
}

#pragma mark - IBAction methods

- (IBAction)onCameraButtonPressed:(id)sender
{
    FLPLogDebug(@"camera button pressed");
    _photoSource = [[FLPCameraPhotoSource alloc] init];
    [self preparePhotosFromSource];
}

- (IBAction)onFacebookButtonPressed:(id)sender
{
    FLPLogDebug(@"Facebook button pressed");
}

- (IBAction)onTwitterButtonPressed:(id)sender
{
    FLPLogDebug(@"Twitter button pressed");
    
    [PFTwitterSignOn setCredentialsWithConsumerKey:kTwitterConsumerKey andSecret:kTwitterSecretKey];
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

        FLPLogDebug(@"login with Twitter successful, with name '%@' and id '%@'", accountInfo[@"name"], accountInfo[@"id"]);
        
    }];
}


# pragma marck UIActionSheetDelegate methods

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

- (void)preparePhotosFromSource
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_photoSource getPhotosFromSource:kMinimunPhotos
                          succesBlock:^(NSArray *photos) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              _photos = photos;
                              
                              // No enough photos available
                              if ((_photos == nil) || (_photos.count < kMinimunPhotos) || ((_photos != nil) && (photos.count == 0))) {
                                  
                                  NSString *message = [self customNoPhotosMessageForSource:_photoSource];
                                  
                                  [WCAlertView showAlertWithTitle:NSLocalizedString(@"MAIN_ALERT", nil)
                                                          message:message
                                               customizationBlock:nil
                                                  completionBlock:nil
                                                cancelButtonTitle:NSLocalizedString(@"OTHER_OK", nil)
                                                otherButtonTitles:nil];
                                  
                              } else {
                                  [self performSegueWithIdentifier:@"gridSegue" sender:self];
                              }
                          }
                         failureBlock:^(NSError *error) {
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         }];
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

    // Other source
    } else {
        message = NSLocalizedString(@"MAIN_ENOUGH_PHOTOS_OTHER", nil);
    }
    
    return message;
}

@end