//
//  FLPGridViewController.m
//  Flip
//
//  Created by Jaime on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPGridViewController.h"

@interface FLPGridViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *backBtn;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

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
    
    // Create an array with duplicate photos indexes, and same size as grid
    // i.e. photosInGrid = [0, 1, 3, 0, 4, 4, 3, 5, 2, 1, 5, 2]
    NSMutableArray *photosInGrid = [[NSMutableArray alloc] init];
    for (int i=0; i < (_size * 2); i++) {
        [photosInGrid addObject:[NSNumber numberWithInt:(i % _size)]];
        //FLPLogDebug(@"add photo to grid %ld", (long)[photosInGrid lastObject]);
    }
    
    // Sort the array randomly
    photosInGrid = [self sortRandomlyArray:photosInGrid];
    
    // Draw images from |photos| array
    NSInteger index = 0;
    FLPLogDebug(@"subviews %ld", (long)_scrollView.subviews.count);
    for (UIView *view in _scrollView.subviews) {
        if (([view isKindOfClass:[UIImageView class]]) && (photosInGrid.count > index)) {
            UIImageView *imageView = (UIImageView *)view;
            NSNumber *photoIndex = (NSNumber *)[photosInGrid objectAtIndex:index];
            UIImage *image = (UIImage *)[_photos objectAtIndex:[photoIndex integerValue]];
            if (image.size.height != image.size.width) {
                [imageView setImage:[self imageCrop:image]];
            } else {
                [imageView setImage:image];
            }
            FLPLogDebug(@"index %ld", (long)index);
            index++;
        }
    }
    
    FLPLogDebug(@"content height before %ld", (long)_scrollView.contentSize.height);
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * 3)];
    FLPLogDebug(@"content height after %ld", (long)_scrollView.contentSize.height);
    [_scrollView setScrollEnabled:YES];
    [_scrollView setClipsToBounds:YES];
    _scrollView.delegate = self;
    FLPLogDebug(@"content size %ld", (long)_scrollView.contentSize.height);
    ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods

- (IBAction)backButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"mainSegue" sender:self];
}

#pragma mark - Private methods

-(UIImage*)imageCrop:(UIImage*)original
{
    UIImage *ret = nil;
    
    // This calculates the crop area.
    
    float originalWidth  = original.size.width;
    float originalHeight = original.size.height;
    
    float edge = fminf(originalWidth, originalHeight);
    
    float posX = (originalWidth   - edge) / 2.0f;
    float posY = (originalHeight  - edge) / 2.0f;
    
    
    CGRect cropSquare = CGRectMake(posX, posY,
                                   edge, edge);
    
    
    // This performs the image cropping.
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([original CGImage], cropSquare);
    
    ret = [UIImage imageWithCGImage:imageRef
                              scale:original.scale
                        orientation:original.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return ret;
}

/**
 *  Sorts the given array randomly
 *  @param array Array to sort randomly
 *  @return The given array sorted randomly
 */
- (NSMutableArray *)sortRandomlyArray:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger numElements = count - i;
        NSUInteger n = (arc4random() % numElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return array;
}

@end
