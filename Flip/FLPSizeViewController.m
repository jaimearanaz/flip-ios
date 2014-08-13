//
//  FLPSizeViewController.m
//  Flip
//
//  Created by Jaime on 06/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPSizeViewController.h"
#import "FLPGridViewController.h"

#import "GADBannerView.h"

@interface FLPSizeViewController ()

@property (nonatomic, weak) IBOutlet UIButton *backBtn;
@property (nonatomic, weak) IBOutlet UIButton *smallBtn;
@property (nonatomic, weak) IBOutlet UIButton *normalBtn;
@property (nonatomic, weak) IBOutlet UIButton *bigBtn;
@property (nonatomic, weak) IBOutlet UIView *bannerView;
@property (nonatomic) GridSizeType size;

- (IBAction)onSmallButtonPressed:(id)sender;
- (IBAction)onNormalButtonPressed:(id)sender;
- (IBAction)onBigButtonPressed:(id)sender;
- (IBAction)onBackButtonPressed:(id)sender;

@end

@implementation FLPSizeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_backBtn setTitle:NSLocalizedString(@"OTHER_BACK", @"") forState:UIControlStateNormal];
    [_smallBtn setTitle:NSLocalizedString(@"SIZE_SMALL", @"") forState:UIControlStateNormal];
    [_normalBtn setTitle:NSLocalizedString(@"SIZE_NORMAL", @"") forState:UIControlStateNormal];
    [_bigBtn setTitle:NSLocalizedString(@"SIZE_BIG", @"") forState:UIControlStateNormal];
    
    // Banner
    GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    banner.adUnitID = kAddMobID;
    banner.rootViewController = self;
    [_bannerView addSubview:banner];
    [banner loadRequest:[GADRequest request]];
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

- (IBAction)onSmallButtonPressed:(id)sender
{
    FLPLogDebug(@"small button pressed");
    _size = GridSizeSmall;
    [self performSegueWithIdentifier:@"gridSegue" sender:self];
}

- (IBAction)onNormalButtonPressed:(id)sender
{
    FLPLogDebug(@"normal button pressed");
    _size = GridSizeNormal;
    [self performSegueWithIdentifier:@"gridSegue" sender:self];
}

- (IBAction)onBigButtonPressed:(id)sender
{
    FLPLogDebug(@"big button pressed");
    _size = GridSizeBig;
    [self performSegueWithIdentifier:@"gridSegue" sender:self];
}

- (IBAction)onBackButtonPressed:(id)sender
{
    FLPLogDebug(@"back button pressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
