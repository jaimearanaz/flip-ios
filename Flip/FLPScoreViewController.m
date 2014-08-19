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
@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
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
// YES if it's a new record
@property (nonatomic) BOOL newRecord;
// Timer to animate new record message
@property (nonatomic, strong) NSTimer *recordTimer;
// Play camera sound
@property (nonatomic, strong) AVAudioPlayer *player;

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
    
    [_tryAgainBtn.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:17]];
    [_tryAgainBtn setTitle:NSLocalizedString(@"SCORE_AGAIN", @"") forState:UIControlStateNormal];

    [_titleLbl setFont:[UIFont fontWithName:@"Pacifico" size:25]];
    _titleLbl.text = NSLocalizedString(@"SCORE_TITLE", @"");
    
    [_timeLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:17]];
    _timeLbl.text = NSLocalizedString(@"SCORE_TIME", @"");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss:SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    [_timeResultLbl setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
    _timeResultLbl.text = [dateFormatter stringFromDate:_time];
    
    [_errorsLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:17]];
    _errorsLbl.text = NSLocalizedString(@"SCORE_ERRORS", @"");
    [_errorsResultLbl setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
    _errorsResultLbl.text = [NSString stringWithFormat:@"%ld", (long)_numOfErrors];
    
    [_penalizationLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:17]];
    _penalizationLbl.text = NSLocalizedString(@"SCORE_PENALIZATION", @"");
    NSTimeInterval penalizationSeconds = _numOfErrors * kPenalizationPerError;
    NSDateFormatter *penalizationDateFormatter = [[NSDateFormatter alloc] init];
    [penalizationDateFormatter setDateFormat:@"mm:ss"];
    [penalizationDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    [_penalizationResultLbl setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
    _penalizationResultLbl.text = [penalizationDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:penalizationSeconds]];
    
    [_finalTimeLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:23]];
    _finalTimeLbl.text = NSLocalizedString(@"SCORE_TIME_FINAL", @"");
    NSDate *finalTime = [NSDate dateWithTimeInterval:penalizationSeconds sinceDate:_time];
    [_finalTimeResultLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:23]];
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
    
    // New record
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *record = (NSDate *)[userDefaults objectForKey:key];
    
    [_nextBtn.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:17]];
    [_recordLbl setFont:[UIFont fontWithName:@"Pacifico" size:23]];
    _recordLbl.text = NSLocalizedString(@"SCORE_RECORD", @"");
    
    if (([record compare:finalTime] == NSOrderedDescending) || (record == nil)) {
        [userDefaults setObject:finalTime forKey:key];
        [_nextBtn setTitle:NSLocalizedString(@"OTHER_NEXT", @"") forState:UIControlStateNormal];
        _recordLbl.hidden = NO;
        _newRecord = YES;
        [self startTimer];
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
    
    // Camera sound
    NSString *cameraSoundPath = [[NSBundle mainBundle] pathForResource:@"polaroid-camera-take-picture-01" ofType:@"wav"];
    NSURL *cameraSoundURL = [NSURL fileURLWithPath:cameraSoundPath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:cameraSoundURL error:nil];
    [_player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self endTimer];
    if ([segue.identifier isEqualToString:@"gridFromScoreSegue"]) {
        FLPGridViewController *gridViewController=(FLPGridViewController *)segue.destinationViewController;
        gridViewController.photos = _photos;
        gridViewController.gridSize = _gridSize;
    }
}

#pragma mark - IBAction methods

- (IBAction)nextButtonPressed:(id)sender
{
    if ([_player isPlaying]) {
        [_player stop];
    }
    
    if (_newRecord) {
        [self performSegueWithIdentifier:@"recordsFromScoreSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"mainFromScoreSegue" sender:self];
    }
}

- (IBAction)tryAgainButtonPressed:(id)sender
{
    if ([_player isPlaying]) {
        [_player stop];
    }
    
    [self performSegueWithIdentifier:@"gridFromScoreSegue" sender:self];
}

#pragma Private methods

- (void)startTimer
{
    if (_recordTimer == nil) {
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(blinkNewRecord)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void)endTimer
{
    if (_recordTimer != nil) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
}

- (void)blinkNewRecord
{
    if (_recordLbl.hidden) {
        _recordLbl.hidden = NO;
    } else {
        _recordLbl.hidden = YES;
    }
}

@end
