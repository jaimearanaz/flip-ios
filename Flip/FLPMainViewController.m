//
//  FLPMainViewController.m
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPMainViewController.h"

#import "RZSquaresLoading.h"

#import "FLPTitleLetterView.h"

#define kSlideAnimationDuration 0.3

@interface FLPMainViewController () <RecordsViewDelegate, SourceViewDelegate, SizeViewDelegate>

@property (weak, nonatomic) IBOutlet TitleView *titleView;
@property (weak, nonatomic) IBOutlet RecordsView *recordsView;
@property (weak, nonatomic) IBOutlet SourceView *sourceView;
@property (weak, nonatomic) IBOutlet SizeView *sizeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordsLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sourceLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeLeading;
@property (weak, nonatomic) IBOutlet UIView *loadingShade;


@property (strong, nonatomic, nonnull) id<MainPresenterDelegate> presenterDelegate;
@property (strong, nonatomic, nullable) Records *records;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) GameSource selectedSource;
@property (strong, nonatomic, nullable) RZSquaresLoading *squareLoading;

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
    self.sizeView.delegate = self;
    
    [self updateRecordsIfReady];
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

#pragma mark - Public methods

- (void)setupViewController:(id<MainPresenterDelegate>)presenterDelegate
{
    self.presenterDelegate = presenterDelegate;
}

#pragma mark - RecordsViewDelegate methods

- (void)didSelectStartGame
{
    [self showSourceView:YES];
}

#pragma mark - SourceViewDelegate methods

- (void)didSelectCamera
{
    self.selectedSource = GameSourceCamera;
    [self showSizeView];
}

- (void)didSelectFacebook
{
    self.selectedSource = GameSourceFacebook;
    [self showSizeView];
}

- (void)didSelectTwitter
{
    self.selectedSource = GameSourceTwitter;
    [self showSizeView];
}

- (void)didSelectRecords
{
    [self showRecordsView];
}

#pragma mark - SizeViewDelegate

- (void)didSelectSmall
{
    [self.presenterDelegate didSelectOptionsWithSource:self.selectedSource size:GameSizeSmall];
}

- (void)didSelectMedium
{
    [self.presenterDelegate didSelectOptionsWithSource:self.selectedSource size:GameSizeMedium];
}

- (void)didSelectBig
{
    [self.presenterDelegate didSelectOptionsWithSource:self.selectedSource size:GameSizeBig];
}

- (void)didSelectShowSource
{
    [self showSourceView:YES];
}

#pragma mark - MainViewControllerDelegate methods

- (void)startLoadingState
{
    self.loadingShade.hidden = NO;
    [self.view bringSubviewToFront:self.loadingShade];
    
    CGRect frame =  CGRectMake(0, 0, 50, 50);
    self.squareLoading = [[RZSquaresLoading alloc] initWithFrame:frame];
    self.squareLoading.center = self.view.center;
    [self.view addSubview:self.squareLoading];
}

- (void)stopLoadingState
{
    self.loadingShade.hidden = YES;
    [self.view sendSubviewToBack:self.loadingShade];
    
    [self.squareLoading removeFromSuperview];
}

- (void)showRecords:(Records *)records
{
    self.records = records;
    [self updateRecordsIfReady];
}

- (void)showSourceViewWithAnimation:(BOOL)withAnimation
{
    [self showSourceView:withAnimation];
}

- (void)showMessage:(NSString *)message
{
    [AlertController showAlertWithMessage:message title:@"" completionBlock:^{}];
}

- (void)showMessage:(MainMessage *)mainMessage leftOption:(void (^)(void))leftOption rightOption:(void (^)(void))rightOption
{
    [AlertController showAlertWithMessage:mainMessage.message
                                    title:nil
                         firstButtonTitle:mainMessage.leftTitle
                        secondButtonTitle:mainMessage.rightTitle
                               firstBlock:^{
                                   leftOption();
                               }
                              secondBlock:^{
                                  rightOption();
                              }];
}

#pragma mark - Private methods

- (void)updateRecordsIfReady
{
    if ((self.recordsView != nil) && (self.records != nil)) {
        [self.recordsView showRecords:self.records];
    }
}

- (void)showRecordsView
{
    [UIView animateWithDuration:kSlideAnimationDuration
                     animations:^{
                         [self updateConstraintsToShowRecordsView];
                         [self.view layoutIfNeeded];
                     }];
    
    [self animateViewsTexts];
}

- (void)showSourceView:(BOOL)animated
{
    if (animated) {
        
        [UIView animateWithDuration:kSlideAnimationDuration
                         animations:^{
                             [self updateConstraintsToShowSourceView];
                             [self.view layoutIfNeeded];
                         }];
        
        [self animateViewsTexts];
        
    } else {

        [self updateConstraintsToShowSourceView];
    }
}

- (void)showSizeView
{
    [UIView animateWithDuration:kSlideAnimationDuration
                     animations:^{
                         [self updateConstraintsToShowSizeView];
                         [self.view layoutIfNeeded];
                     }];
    
    [self animateViewsTexts];
}

- (void)updateConstraintsToShowRecordsView
{
    self.recordsLeading.constant = 0;
    self.sourceLeading.constant = self.screenWidth;
    self.sizeLeading.constant = self.screenWidth * 2;
}

- (void)updateConstraintsToShowSourceView
{
    self.recordsLeading.constant = -self.screenWidth;
    self.sourceLeading.constant = 0;
    self.sizeLeading.constant = self.screenWidth;
}

- (void)updateConstraintsToShowSizeView
{
    self.recordsLeading.constant = -(self.screenWidth * 2);
    self.sourceLeading.constant = -self.screenWidth;
    self.sizeLeading.constant = 0;
}

- (void)animateViewsTexts
{
    self.sourceView.title.alpha = 0;
    self.sourceView.showRecords.alpha = 0;
    
    self.sizeView.title.alpha = 0;
    self.sizeView.showSource.alpha = 0;
    
    [UIView animateWithDuration:kSlideAnimationDuration
                          delay:kSlideAnimationDuration
                        options:0
                     animations:^{
                         
                         self.sourceView.title.alpha = 1;
                         self.sourceView.showRecords.alpha = 1;
                         
                         self.sizeView.title.alpha = 1;
                         self.sizeView.showSource.alpha = 1;
                         
                     } completion:^(BOOL finished) {}];
}

@end
