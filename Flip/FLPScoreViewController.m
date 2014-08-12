//
//  FLPScoreViewController.m
//  Flip
//
//  Created by Jaime on 12/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPScoreViewController.h"

@interface FLPScoreViewController ()

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UILabel *timeLbl;
@property (nonatomic, weak) IBOutlet UILabel *timeResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *errorsLbl;
@property (nonatomic, weak) IBOutlet UILabel *errorsResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *penalizationLbl;
@property (nonatomic, weak) IBOutlet UILabel *penalizationResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *finalTimeLbl;
@property (nonatomic, weak) IBOutlet UILabel *finalTimeResultLbl;

- (IBAction)nextButtonPressed:(id)sender;

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
    
    [_nextBtn setTitle:NSLocalizedString(@"OTHER_NEXT", @"") forState:UIControlStateNormal];
    
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
    
    _finalTimeLbl.text = NSLocalizedString(@"SCORE_FINAL_TIME", @"");
    NSDate *finalTime = [NSDate dateWithTimeInterval:penalizationSeconds sinceDate:_time];
    _finalTimeResultLbl.text = [dateFormatter stringFromDate:finalTime];
}

- (void)updateTimer
{
    /*
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_startDate];
    _endDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:_endDate];
    _timerLbl.text = timeString;
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction methods

- (IBAction)nextButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"mainSegue" sender:self];
}

@end
