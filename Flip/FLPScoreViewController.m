//
//  FLPScoreViewController.m
//  Flip
//
//  Created by Jaime on 12/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPScoreViewController.h"

#import "GADBannerView.h"

@interface FLPScoreViewController ()

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UIButton *tryAgainBtn;
@property (nonatomic, weak) IBOutlet UILabel *timeLbl;
@property (nonatomic, weak) IBOutlet UILabel *timeResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *errorsLbl;
@property (nonatomic, weak) IBOutlet UILabel *errorsResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *penalizationLbl;
@property (nonatomic, weak) IBOutlet UILabel *penalizationResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *finalTimeLbl;
@property (nonatomic, weak) IBOutlet UILabel *finalTimeResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *recordLbl;
@property (nonatomic, weak) IBOutlet UIView *bannerView;
@property (nonatomic) BOOL newRecord;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)tryAgainButtonPressed:(id)sender;

@end

@implementation FLPScoreViewController

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
    
    [_tryAgainBtn setTitle:NSLocalizedString(@"SCORE_AGAIN", @"") forState:UIControlStateNormal];
    
    _timeLbl.text = NSLocalizedString(@"SCORE_TIME", @"");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss:SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    _timeResultLbl.text = [dateFormatter stringFromDate:_time];
    
    _errorsLbl.text = NSLocalizedString(@"SCORE_ERRORS", @"");
    _errorsResultLbl.text = [NSString stringWithFormat:@"%ld", (long)_numOfErrors];
    
    _penalizationLbl.text = NSLocalizedString(@"SCORE_PENALIZATION", @"");
    NSTimeInterval penalizationSeconds = _numOfErrors * kPenalizationPerError;
    NSDateFormatter *penalizationDateFormatter = [[NSDateFormatter alloc] init];
    [penalizationDateFormatter setDateFormat:@"mm:ss"];
    [penalizationDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    _penalizationResultLbl.text = [penalizationDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:penalizationSeconds]];
    
    _finalTimeLbl.text = NSLocalizedString(@"SCORE_TIME_FINAL", @"");
    NSDate *finalTime = [NSDate dateWithTimeInterval:penalizationSeconds sinceDate:_time];
    _finalTimeResultLbl.text = [dateFormatter stringFromDate:finalTime];
    
    NSString *key = @"";
    switch (_gridSize) {
        case GridSizeSmall:
            key = @"small";
            break;
        case GridSizeNormal:
            key = @"normal";
            break;
        case GridSizeBig:
            key = @"big";
            break;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *record = (NSDate *)[userDefaults objectForKey:key];
    
    _recordLbl.text = NSLocalizedString(@"SCORE_RECORD", @"");
    if (([record compare:finalTime] == NSOrderedDescending) || (record == nil)) {
        [userDefaults setObject:finalTime forKey:key];
        [_nextBtn setTitle:NSLocalizedString(@"OTHER_NEXT", @"") forState:UIControlStateNormal];
        _recordLbl.hidden = NO;
        _newRecord = YES;
    } else {
        [_nextBtn setTitle:NSLocalizedString(@"OTHER_MAIN", @"") forState:UIControlStateNormal];
        _recordLbl.hidden = YES;
        _newRecord = NO;
    }
    
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
    if ([segue.identifier isEqualToString:@"gridFromScoreSegue"]) {
        FLPGridViewController *gridViewController=(FLPGridViewController *)segue.destinationViewController;
        gridViewController.photos = _photos;
        gridViewController.gridSize = _gridSize;
    }
}

#pragma mark - IBAction methods

- (IBAction)nextButtonPressed:(id)sender
{
    if (_newRecord) {
        [self performSegueWithIdentifier:@"recordSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"mainSegue" sender:self];
    }
}

- (IBAction)tryAgainButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"gridFromScoreSegue" sender:self];
}

@end
