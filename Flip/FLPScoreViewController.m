//
//  FLPScoreViewController.m
//  Flip
//
//  Created by Jaime Aranaz on 12/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "FLPScoreViewController.h"
#import "FLPMainScrenViewController.h"

@interface FLPScoreViewController ()

@property (nonatomic, weak) IBOutlet UIButton *mainBtn;
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
// Timer to animate new record
@property (nonatomic, strong) NSTimer *recordTimer;
// Flag to count new record blinks
@property (nonatomic) NSInteger numberBlinks;
// Play camera sound effect
@property (nonatomic, strong) AVAudioPlayer *playerCamera;

- (IBAction)onMainButtonPressed:(id)sender;
- (IBAction)onTryAgainButtonPressed:(id)sender;

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
    } else if (height == kiPhone6PlusHeight) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
        // It's other iPhone
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Custom fonts and size must be set using Size Class within Interface Builder
    // However, there is no way to use it form IB, it doesn't work (maybe is it a bug?)
    
    CGFloat titleSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? kiPadTitleFontSize : kiPhoneTitleFontSize;
    CGFloat mainSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? kiPadMainFontSize : kiPhoneMainFontSize;
    CGFloat bigSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? kiPadBigFontSize : kiPhoneBigFontSize;

    [_tryAgainBtn.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:kiPhoneMainFontSize]];
    [self.tryAgainBtn setTitle:NSLocalizedString(@"SCORE_AGAIN", @"") forState:UIControlStateNormal];
    
    [_mainBtn.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:kiPhoneMainFontSize]];
    [self.mainBtn setTitle:NSLocalizedString(@"OTHER_MAIN", @"") forState:UIControlStateNormal];

    [_titleLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:titleSize]];
    self.titleLbl.text = NSLocalizedString(@"SCORE_TITLE", @"");
    
    // User scores
    
    [_timeLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:mainSize]];
    self.timeLbl.text = NSLocalizedString(@"SCORE_TIME", @"");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss:SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    [_timeResultLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:mainSize]];
    self.timeResultLbl.text = [dateFormatter stringFromDate:self.time];
    
    [_errorsLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:mainSize]];
    self.errorsLbl.text = NSLocalizedString(@"SCORE_ERRORS", @"");
    [_errorsResultLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:mainSize]];
    self.errorsResultLbl.text = [NSString stringWithFormat:@"%ld", (long)self.numOfErrors];
    
    [_penalizationLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:mainSize]];
    self.penalizationLbl.text = NSLocalizedString(@"SCORE_PENALIZATION", @"");
    NSTimeInterval penalizationSeconds = self.numOfErrors * kPenalizationPerError;
    NSDateFormatter *penalizationDateFormatter = [[NSDateFormatter alloc] init];
    [penalizationDateFormatter setDateFormat:@"mm:ss"];
    [penalizationDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    [_penalizationResultLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:mainSize]];
    self.penalizationResultLbl.text = [penalizationDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:penalizationSeconds]];
    
    // Final time
    
    [_finalTimeLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:bigSize]];
    self.finalTimeLbl.text = NSLocalizedString(@"SCORE_TIME_FINAL", @"");
    NSDate *finalTime = [NSDate dateWithTimeInterval:penalizationSeconds sinceDate:self.time];
    [_finalTimeResultLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:bigSize]];
    self.finalTimeResultLbl.text = [dateFormatter stringFromDate:finalTime];
    
    // It's a new record ?
    
    NSString *key = @"";
    switch (self.gridSize) {
        case GridSizeSmall:
            key = @"small";
            break;
        case GridSizeMedium:
            key = @"normal";
            break;
        case GridSizeBig:
            key = @"big";
            break;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *record = (NSDate *)[userDefaults objectForKey:key];

    [_recordLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:bigSize]];
    self.recordLbl.text = NSLocalizedString(@"SCORE_RECORD", @"");
    
    // It's a record, save it
    if (([record compare:finalTime] == NSOrderedDescending) || (record == nil)) {
        [userDefaults setObject:finalTime forKey:key];
        self.recordLbl.hidden = NO;
        self.newRecord = YES;
        self.numberBlinks = 0;
        [self startTimer];
        
    // No record
    } else {
        self.recordLbl.hidden = YES;
        self.newRecord = NO;
    }
    
    // Configure banner
//    GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
//    // AdMob key is stored in a plist file, not tracked in git repository
//    NSString *adMobPlist = [[NSBundle mainBundle] pathForResource:@"AdMobKey" ofType:@"plist"];
//    NSDictionary *adMobKey = [[NSDictionary alloc] initWithContentsOfFile:adMobPlist];
//    banner.adUnitID = [adMobKey objectForKey:@"key"];
//    banner.rootViewController = self;
//    [self.bannerView addSubview:banner];
//    [banner loadRequest:[GADRequest request]];
    
    // Camera sound, play only if no other sound is playing (i.e. music player)
    if (![[AVAudioSession sharedInstance] isOtherAudioPlaying]) {
        NSString *cameraSoundPath = [[NSBundle mainBundle] pathForResource:@"polaroid-camera-take-picture-01" ofType:@"wav"];
        NSURL *cameraSoundURL = [NSURL fileURLWithPath:cameraSoundPath];
        self.playerCamera = [[AVAudioPlayer alloc] initWithContentsOfURL:cameraSoundURL error:nil];
        [self.playerCamera play];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self endTimer];
    
    if (_playerCamera) {
        [_playerCamera stop];
        _playerCamera = nil;
    }
    
    // User tries again
    if ([segue.identifier isEqualToString:@"gridFromScoreSegue"]) {
        FLPGridViewController *gridViewController = (FLPGridViewController *)segue.destinationViewController;
        gridViewController.photos = _photos;
        gridViewController.gridSize = _gridSize;
        
    // User continues to main screen
    } else if (([segue.identifier isEqualToString:@"mainFromScoreSegue"]) && (_newRecord)) {
        FLPMainScrenViewController *mainViewController = (FLPMainScrenViewController *)segue.destinationViewController;
        mainViewController.startWithRecordsView = YES;
    }
}

#pragma mark - IBAction methods

- (IBAction)onMainButtonPressed:(id)sender
{
    if ([_playerCamera isPlaying]) { 
        [_playerCamera stop];
    }
    
    [self performSegueWithIdentifier:@"mainFromScoreSegue" sender:self];
}

- (IBAction)onTryAgainButtonPressed:(id)sender
{
    if ([_playerCamera isPlaying]) {
        [_playerCamera stop];
    }
    
    [self performSegueWithIdentifier:@"gridFromScoreSegue" sender:self];
}

#pragma Private methods

/**
 * Starts timer to animate new record
 */
- (void)startTimer
{
    if (_recordTimer == nil) {
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(blinkNewRecord)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

/**
 * Ends timer used to animate new record
 */
- (void)endTimer
{
    if (_recordTimer != nil) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
}

/**
 * Blink new record effect
 */
- (void)blinkNewRecord
{
    if (_finalTimeResultLbl.hidden) {
        _finalTimeResultLbl.hidden = NO;
    } else {
        _numberBlinks++;
        _finalTimeResultLbl.hidden = YES;
    }
    
    if (_numberBlinks == 4) {
        [self endTimer];
        _finalTimeResultLbl.hidden = NO;
    }
}

@end
