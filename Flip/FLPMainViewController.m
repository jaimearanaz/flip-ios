//
//  FLPMainViewController.m
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPMainViewController.h"

#import "FLPTitleLetterView.h"

@interface FLPMainViewController () <SourceViewDelegate>

@property (weak, nonatomic) IBOutlet TitleView *titleView;
@property (weak, nonatomic) IBOutlet SourceView *sourceView;

@end

@implementation FLPMainViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sourceView.delegate = self;
    [self.titleView startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.titleView stopAnimation];
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
    // TODO: implement
}

#pragma mark - MainViewControllerDelegate methods

- (void)showRecordsWithSmall:(NSTimeInterval)small medium:(NSTimeInterval)medium big:(NSTimeInterval)big
{
    // TODO: implement
}

@end
