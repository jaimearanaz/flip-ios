//
//  FLPGridViewController.m
//  Flip
//
//  Created by Jaime on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPGridViewController.h"
#import "FLPCollectionViewCell.h"

@interface FLPGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIButton *backBtn;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

// This array represents the duplicate photos in grid, identified by its indexes inside |photos|
// Grid will be build up with the same array order
// i.e. photosInGrid = [0, 1, 3, 0, 4, 4, 3, 5, 2, 1, 5, 2]
@property (nonatomic, strong) NSMutableArray *photosInGrid;

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
    
    // Configure |photosInGrid|, for example [0, 1, 3, 0, 4, 4, 3, 5, 2, 1, 5, 2]
    _photosInGrid = [[NSMutableArray alloc] init];
    for (int i=0; i < (_size * 2); i++) {
        [_photosInGrid addObject:[NSNumber numberWithInt:(i % _size)]];
        FLPLogDebug(@"add photo to grid %ld", (long)[(NSNumber *)[_photosInGrid lastObject] integerValue]);
    }
    
    // Sort the array randomly
    _photosInGrid = [self sortRandomlyArray:_photosInGrid];
}

- (void)viewDidAppear:(BOOL)animated
{
    double delay;
    switch (_size) {
        case kGridSizeSmall:
            delay = kGridDelaySmall;
            break;
        case kGridSizeNormal:
            delay = kGridDelayNormal;
            break;
        case kGridSizeBig:
            delay = kGridDelayBig;
            break;
        default:
            delay = kGridDelaySmall;
    }
    
    for (int i=0; i < (_size * 2); i++) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell performSelector:@selector(flipCellAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
        delay += 0.1;
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
    [self performSegueWithIdentifier:@"mainSegue" sender:self];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (_size * 2);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gridCell" forIndexPath:indexPath];
    cell.imageIndex = [(NSNumber *)[_photosInGrid objectAtIndex:indexPath.row] integerValue];
    FLPLogDebug(@"cell index %ld", (long)cell.imageIndex);
    UIImage *image = (UIImage *)[_photos objectAtIndex:cell.imageIndex];
    if (image.size.height != image.size.width) {
        [cell.imageView setImage:[self imageCrop:image]];
    } else {
        [cell.imageView setImage:image];
    }
    cell.coverLbl.text = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];
    
    [cell.contentView bringSubviewToFront:cell.imageView];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLPCollectionViewCell *cell = (FLPCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell flipCellAnimated:[NSNumber numberWithBool:YES]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 90);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
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
