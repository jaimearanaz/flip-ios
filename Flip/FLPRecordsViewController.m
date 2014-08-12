//
//  FLPRecordsViewController.m
//  Flip
//
//  Created by Jaime on 12/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPRecordsViewController.h"

@interface FLPRecordsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
@property (nonatomic, weak) IBOutlet UILabel *smallLbl;
@property (nonatomic, weak) IBOutlet UILabel *smallResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *normalLbl;
@property (nonatomic, weak) IBOutlet UILabel *normalResultLbl;
@property (nonatomic, weak) IBOutlet UILabel *bigLbl;
@property (nonatomic, weak) IBOutlet UILabel *bigResultLbl;
@property (nonatomic, weak) IBOutlet UIButton *mainBtn;

- (IBAction)mainButtonPressed:(id)sender;

@end

@implementation FLPRecordsViewController

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
    
    [_mainBtn setTitle:NSLocalizedString(@"OTHER_MAIN", @"") forState:UIControlStateNormal];
    _titleLbl.text = NSLocalizedString(@"RECORDS_TITLE", @"");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *recordSmall = (NSDate *)[userDefaults objectForKey:@"small"];
    NSDate *recordNormal = (NSDate *)[userDefaults objectForKey:@"normal"];
    NSDate *recordBig = (NSDate *)[userDefaults objectForKey:@"big"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss:SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    _smallLbl.text = NSLocalizedString(@"RECORDS_SMALL", @"");
    _smallResultLbl.text = (recordSmall) ? [dateFormatter stringFromDate:recordSmall] : NSLocalizedString(@"RECORDS_NONE", @"");
    
    _normalLbl.text = NSLocalizedString(@"RECORDS_NORMAL", @"");
    _normalResultLbl.text = (recordNormal) ? [dateFormatter stringFromDate:recordNormal] : NSLocalizedString(@"RECORDS_NONE", @"");
    
    _bigLbl.text = NSLocalizedString(@"RECORDS_BIG", @"");
    _bigResultLbl.text = (recordBig) ? [dateFormatter stringFromDate:recordBig] : NSLocalizedString(@"RECORDS_NONE", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods

- (IBAction)mainButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"mainFromRecordSegue" sender:self];
}

@end
