//
//  FLPScoreViewController.m
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPScoreViewController.h"

@interface FLPScoreViewController ()

@property (weak, nonatomic) IBOutlet UIButton *tryAgain;
@property (weak, nonatomic) IBOutlet UIButton *main;
@property (weak, nonatomic) IBOutlet ScoreView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *recordView;

@property (strong, nonatomic) NSTimer *recordBlinkTimer;
@property (nonatomic) BOOL hideScores;

@end

@implementation FLPScoreViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeTexts];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.hideScores) {
        [self.scoreView hideScore];
        self.hideScores = NO;
    }
}

#pragma mark - Action methods

- (IBAction)didSelectTryAgain
{
    [self.presenterDelegate didSelectTryAgain];
    [self stopBlinking];
    self.hideScores = YES;
}

- (IBAction)didSelectMain
{
    [self.presenterDelegate didSelectMain];
    [self stopBlinking];
    self.hideScores = YES;
}

#pragma mark - ScoreViewControllerDelegate methods

- (void)showScore:(Score *)score isNewRecord:(BOOL)isNewRecord
{
    [self.scoreView showScore:score];
    if (isNewRecord) {
        [self startBlinking];
    }
}

#pragma mark - Private methods

- (void)localizeTexts
{
    self.recordView.text = NSLocalizedString(@"SCORE_RECORD", @"New record message");
}

- (void)startBlinking
{
    if (self.recordBlinkTimer == nil) {
        self.recordBlinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(blinkNewRecord)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void)stopBlinking
{
    if (self.recordBlinkTimer != nil) {
        [self.recordBlinkTimer invalidate];
        self.recordBlinkTimer = nil;
    }
}

- (void)blinkNewRecord
{
    if (self.recordView.hidden) {
        self.recordView.hidden = NO;
    } else {
        self.recordView.hidden = YES;
    }
}

@end
