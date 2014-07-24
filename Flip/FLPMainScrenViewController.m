//
//  FLPViewController.m
//  Flip
//
//  Created by Jaime on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPMainScrenViewController.h"
#import "FLPCameraPhotoSource.h"
#import "FLPGridViewController.h"

#import "MBProgressHUD.h"

@interface FLPMainScrenViewController ()

@property (nonatomic, weak) IBOutlet UILabel *selectLbl;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property (nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property (nonatomic, weak) IBOutlet UIButton *recordsBtn;
@property (nonatomic, strong) __block NSArray *photos;

- (IBAction)onCameraButtonPressed:(id)sender;
- (IBAction)onFacebookButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;

@end

@implementation FLPMainScrenViewController

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
    _twitterBtn.enabled = NO;}

#pragma mark - IBAction methods

- (IBAction)onCameraButtonPressed:(id)sender
{
    FLPLogDebug(@"camera button pressed");
    FLPCameraPhotoSource *cameraSource = [[FLPCameraPhotoSource alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [cameraSource getPhotosFromSource:10
                          succesBlock:^(NSArray *photos) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              _photos = photos;
                              [self performSegueWithIdentifier:@"gridSegue" sender:self];
                          }
                         failureBlock:^(NSError *error) {
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         }];

}

- (IBAction)onFacebookButtonPressed:(id)sender
{
    FLPLogDebug(@"Facebook button pressed");
}

- (IBAction)onTwitterButtonPressed:(id)sender
{
    FLPLogDebug(@"Twitter button pressed");
}

@end
