//
//  FLPViewController.m
//  Flip
//
//  Created by Jaime on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPMainScrenViewController.h"

@interface FLPMainScrenViewController ()

@property (nonatomic, weak) IBOutlet UILabel *selectLbl;
@property (nonatomic, weak) IBOutlet UIButton *cameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property (nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property (nonatomic, weak) IBOutlet UIButton *recordsBtn;

@end

@implementation FLPMainScrenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _selectLbl.text = NSLocalizedString(@"MAIN_SELECT", @"");
    _cameraBtn.titleLabel.text = NSLocalizedString(@"MAIN_CAMERA", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
