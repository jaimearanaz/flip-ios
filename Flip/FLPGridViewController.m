//
//  FLPGridViewController.m
//  Flip
//
//  Created by Jaime on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPGridViewController.h"

@interface FLPGridViewController ()

@property (nonatomic, weak) IBOutlet UIButton *backBtn;

- (IBAction)backButtonPressed:(id)sender;

@end

@implementation FLPGridViewController

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
    
    [_backBtn setTitle:NSLocalizedString(@"OTHER_BACK", @"") forState:UIControlStateNormal];
    
    // Draw images from |photos| array
    NSInteger index = 0;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && (_photos.count > index)) {
            UIImageView *imageView = (UIImageView *)view;
            [imageView setImage:[_photos objectAtIndex:index]];
            index++;
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
