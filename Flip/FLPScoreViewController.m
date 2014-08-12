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
@property (nonatomic, weak) IBOutlet UILabel *recordLbl;
@property (nonatomic) BOOL newRecord;

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
    switch (_sizeType) {
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
