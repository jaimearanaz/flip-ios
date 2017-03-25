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
@property (weak, nonatomic) IBOutlet ScoreView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *recordView;

@property (strong, nonatomic) NSTimer *recordBlinkTimer;

@end

@implementation FLPNewScoreViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeTexts];
}

#pragma mark - Action methods

- (IBAction)didSelectTryAgain
{
    [self.presenterDelegate didSelectTryAgain];
    [self stopBlinking];
}

- (IBAction)didSelectMain
{
    [self.presenterDelegate didSelectMain];
    [self stopBlinking];
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
