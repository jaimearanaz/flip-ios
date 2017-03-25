//
//  FLPNewScoreViewController.m
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPNewScoreViewController.h"

@interface FLPNewScoreViewController ()

@property (weak, nonatomic) IBOutlet UIButton *tryAgain;
@property (weak, nonatomic) IBOutlet UIButton *main;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *recordView;

@end

@implementation FLPNewScoreViewController

#pragma mark - ScoreViewControllerDelegate methods

- (void)showScore:(Score *)score isNewRecord:(BOOL)isNewRecord
{
    // TODO: implement
}

@end
