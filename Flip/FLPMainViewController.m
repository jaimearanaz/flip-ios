//
//  FLPMainViewController.m
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPMainViewController.h"

#import "FLPTitleLetterView.h"

#define kSlideAnimationDuration 0.3

@interface FLPMainViewController () <SourceViewDelegate, RecordsViewDelegate>

@property (weak, nonatomic) IBOutlet TitleView *titleView;
@property (weak, nonatomic) IBOutlet RecordsView *recordsView;
@property (weak, nonatomic) IBOutlet SourceView *sourceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordsLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sourceLeading;

@property (nonatomic) CGFloat screenWidth;

@end

@implementation FLPMainViewController

#pragma mark - Lifecycle methods

- (CGFloat)screenWidth
{
    if (_screenWidth == 0) {
        _screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    
    return _screenWidth;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.titleView startAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recordsView.delegate = self;
    self.sourceView.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.titleView stopAnimation];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self showSourceView:NO];
}

#pragma mark - RecordsViewDelegate methods

- (void)didSelectStartGame
{
    [self showSourceView:YES];
}

#pragma mark - SourceViewDelegate methods

- (void)didSelectCamera
{
    // TODO: implement
}

- (void)didSelectFacebook
{
    // TODO: implement
}

- (void)didSelectTwitter
{
    // TODO: implement
}

- (void)didSelectRecords
{
    [self showRecordsView];
}

#pragma mark - MainViewControllerDelegate methods

- (void)showRecordsWithSmall:(NSTimeInterval)small medium:(NSTimeInterval)medium big:(NSTimeInterval)big
{
    // TODO: implement
}

#pragma mark - Private methods

- (void)showRecordsView
{
    [UIView animateWithDuration:kSlideAnimationDuration
                     animations:^{
                         [self updateConstraintsToShowRecordsView];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)showSourceView:(BOOL)animated
{
    if (animated) {
        
        [UIView animateWithDuration:kSlideAnimationDuration
                         animations:^{
                             [self updateConstraintsToShowSourceView];
                             [self.view layoutIfNeeded];
                         }];
    } else {

        [self updateConstraintsToShowSourceView];
    }
}

- (void)updateConstraintsToShowRecordsView
{
    self.recordsLeading.constant = 0;
    self.sourceLeading.constant = self.screenWidth;
}

- (void)updateConstraintsToShowSourceView
{
    self.sourceLeading.constant = 0;
    self.recordsLeading.constant = -self.screenWidth;
}

@end
