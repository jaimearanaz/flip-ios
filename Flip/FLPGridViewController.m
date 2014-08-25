//
//  FLPGridViewController.m
//  Flip
//
//  Created by Jaime Aranaz on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPGridViewController.h"
#import "FLPCollectionViewCell.h"
#import "FLPGridItem.h"
#import "FLPScoreViewController.h"

#import "WCAlertView.h"
#import "GADBannerView.h"

@interface FLPGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIButton *backBtn;
@property (nonatomic, weak) IBOutlet UILabel *timerLbl;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *bannerView;

// Constraint used to remove banner when iPhone is 3.5 inchs and grid size is small
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bannerConstraint;

// Array with the duplicated images in grid, it represents indexes from |photos| array
// e.g. [0, 1, 3, 0, 4, 4, 3, 5, 2, 1, 5, 2]
@property (nonatomic, strong) NSMutableArray *photosInGrid;
// Total number of images in grid
@property (nonatomic) NSInteger numOfPhotos;
// Number of images matched in grid
@property (nonatomic) NSInteger numOfPhotosMatched;
// Number of errors trying to match images in grid
@property (nonatomic) NSInteger numOfErrors;
// Starting game time
@property (nonatomic) NSDate *startDate;
// Ending game time
@property (nonatomic) NSDate *endDate;
// Timer to update game timing
@property (nonatomic, strong) NSTimer *timer;
// First image to try match
@property (nonatomic) FLPGridItem *firstPhoto;
// Second image to try match
@property (nonatomic) FLPGridItem *secondPhoto;
// YES if game has started, NO if photos are being showed to user
@property (nonatomic) NSNumber *started;
// Play camera sound effect when photos are matched
@property (nonatomic, strong) AVAudioPlayer *playerCamera;

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
    
    switch (_gridSize) {
        case GridSizeSmall:
            _numOfPhotos = kGridSmallPhotos;
            break;
        case GridSizeMedium:
            _numOfPhotos = kGridNormalPhotos;
            break;
        case GridSizeBig:
            _numOfPhotos = kGridBigPhotos;
            break;
        default:
            break;
    }
    
    _numOfPhotosMatched = 0;
    _numOfErrors = 0;

    [_backBtn.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:17]];
    [_backBtn setTitle:NSLocalizedString(@"OTHER_EXIT", @"") forState:UIControlStateNormal];
    [_timerLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:20]];
    
    // Configure |photosInGrid|, for example [0, 1, 3, 0, 4, 4, 3, 5, 2, 1, 5, 2]
    _photosInGrid = [[NSMutableArray alloc] init];
    for (int i=0; i < (_numOfPhotos); i++) {
        FLPGridItem *gridItem = [[FLPGridItem alloc] init];
        gridItem.imageIndex = (i % (_numOfPhotos/2));
        gridItem.isShowing = [NSNumber numberWithBool:YES];
        gridItem.isMatched = [NSNumber numberWithBool:NO];
        [_photosInGrid addObject:gridItem];
    }
    
    // Sort the array randomly
    _photosInGrid = [self sortRandomlyArray:_photosInGrid];
    
    // Configure banner
    GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // AdMob key is stored in a plist file, not tracked in git repository
    NSString *adMobPlist = [[NSBundle mainBundle] pathForResource:@"AdMobKey" ofType:@"plist"];
    NSDictionary *adMobKey = [[NSDictionary alloc] initWithContentsOfFile:adMobPlist];
    banner.adUnitID = [adMobKey objectForKey:@"key"];
    banner.rootViewController = self;
    [_bannerView addSubview:banner];
    [banner loadRequest:[GADRequest request]];
    
    // If 3.5 inches and small grid, remove banner for better performance
    if ((!isiPhone5) && (_gridSize == GridSizeSmall)) {
        [self.view removeConstraint:_bannerConstraint];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Camera sound, play only if no other sound is playing (i.e. music player)
    NSString *cameraSoundPath = [[NSBundle mainBundle] pathForResource:@"camera-shutter-click-01" ofType:@"wav"];
    NSURL *cameraSoundURL = [NSURL fileURLWithPath:cameraSoundPath];
    _playerCamera = [[AVAudioSession sharedInstance] isOtherAudioPlaying] ? nil : [[AVAudioPlayer alloc] initWithContentsOfURL:cameraSoundURL error:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Free player
    if (_playerCamera) {
        [_playerCamera stop];
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![_started boolValue]) {
        double delay;
        switch (_gridSize) {
            case GridSizeSmall:
                delay = kGridSmallDelay;
                break;
            case GridSizeMedium:
                delay = kGridMediumDelay;
                break;
            case GridSizeBig:
                delay = kGridBigDelay;
                break;
            default:
                delay = kGridSmallDelay;
        }
        [self performSelector:@selector(startGame)
                   withObject:nil
                   afterDelay:delay
                      inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (_playerCamera) {
        [_playerCamera stop];
    }
    
    if ([segue.identifier isEqualToString:@"scoreFromGridSegue"]) {
        FLPScoreViewController *scoreViewController=(FLPScoreViewController *)segue.destinationViewController;
        scoreViewController.time = _endDate;
        scoreViewController.numOfErrors = _numOfErrors;
        scoreViewController.gridSize = _gridSize;
        scoreViewController.photos = _photos;
    }
}

#pragma mark - IBAction methods

- (IBAction)backButtonPressed:(id)sender
{
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"GRID_EXIT", @"")
                            message:NSLocalizedString(@"GRID_EXIT_CONFIRM", @"")
                 customizationBlock:nil
                    completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 1) {
                            [self exitGame];
                        }
                    }
                  cancelButtonTitle:NSLocalizedString(@"OTHER_CANCEL", @"")
                  otherButtonTitles:NSLocalizedString(@"OTHER_YES", @""), nil];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (_numOfPhotos);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gridCell" forIndexPath:indexPath];
    FLPGridItem *gridItem = [_photosInGrid objectAtIndex:indexPath.row];
    
    // Configure cell
    UIImage *image = (UIImage *)[_photos objectAtIndex:gridItem.imageIndex];
    if (image.size.height != image.size.width) {
        [cell.photoView setImage:[self imageCrop:image]];
    } else {
        [cell.photoView setImage:image];
    }
    [cell.coverLbl setFont:[UIFont fontWithName:@"CantoraOne-Regular" size:40]];
    cell.coverLbl.text = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];

    // Game is not started yet, show all images
    if ((![_started boolValue]) && ([gridItem.isShowing boolValue])) {
        [cell flipCellToImageAnimated:[NSNumber numberWithBool:NO] onCompletion:nil];
        
    // Game is started
    } else {
        
        // Matched
        if ([gridItem.isMatched boolValue]) {
            [cell flipCellToImageAnimated:[NSNumber numberWithBool:NO] onCompletion:nil];
        } else {
            // Selected
            if ([gridItem.isShowing boolValue]) {
                [cell flipCellToImageAnimated:[NSNumber numberWithBool:NO] onCompletion:nil];
            // Not selected
            } else {
                [cell flipCellToCoverAnimated:[NSNumber numberWithBool:NO]];
            }
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLPCollectionViewCell *cell = (FLPCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    FLPGridItem *gridItem = [_photosInGrid objectAtIndex:indexPath.row];

    // Game is running and new photo has been selected
    if (([_started boolValue]) &&
        (_secondPhoto == nil) &&
        ([gridItem.isMatched boolValue] == NO) &&
        ([gridItem.isShowing boolValue] == NO)) {

        // It's first photo
        if (_firstPhoto == nil) {
            gridItem.isShowing = [NSNumber numberWithBool:YES];
            _firstPhoto = gridItem;
            [cell flipCellToImageAnimated:[NSNumber numberWithBool:YES] onCompletion:nil];
            
        // It's second photo
        } else {
            
            if (gridItem != _firstPhoto) {
                gridItem.isShowing = [NSNumber numberWithBool:YES];
                _secondPhoto = gridItem;
                
                NSInteger firstPhotoRow = [_photosInGrid indexOfObject:_firstPhoto];
                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:firstPhotoRow inSection:0];
                FLPCollectionViewCell *firstCell = (FLPCollectionViewCell *)[_collectionView cellForItemAtIndexPath:firstIndexPath];
                FLPCollectionViewCell *secondCell = cell;
                
                // Photos match, keep showing
                if (_firstPhoto.imageIndex == _secondPhoto.imageIndex) {
                    
                        [cell flipCellToImageAnimated:[NSNumber numberWithBool:YES] onCompletion:^{
                            
                            // Flash animation
                            [firstCell matchedAnimation];
                            [secondCell matchedAnimation];
                            
                            // Camera sound
                            if (_playerCamera) {
                                [_playerCamera play];
                            }
                            
                            _firstPhoto.isMatched = [NSNumber numberWithBool:YES];
                            _firstPhoto = nil;
                            _secondPhoto.isMatched = [NSNumber numberWithBool:YES];
                            _secondPhoto = nil;
                            _numOfPhotosMatched += 2;
                            
                            // All photos matched, return to main view
                            if (_numOfPhotosMatched == _numOfPhotos) {
                                [self stopTimer];
                                
                                // Final time
                                NSDate *currentDate = [NSDate date];
                                NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_startDate];
                                _endDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                                
                                [self performSelector:@selector(endGame)
                                           withObject:nil
                                           afterDelay:kGridGeneralDelay
                                              inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
                            }
                        }];
                    
                // Photos don't match, hide them
                } else {
                    [cell flipCellToImageAnimated:[NSNumber numberWithBool:YES] onCompletion:^{
                        [firstCell flipCellToCoverAnimated:[NSNumber numberWithBool:YES]];
                        [secondCell flipCellToCoverAnimated:[NSNumber numberWithBool:YES]];
                        _firstPhoto.isShowing = [NSNumber numberWithBool:NO];
                        _firstPhoto = nil;
                        _secondPhoto.isShowing = [NSNumber numberWithBool:NO];
                        _secondPhoto = nil;
                        _numOfErrors++;
                    }];
                }
            }
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 100);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}

#pragma mark - Private methods

/**
 *  Starts game hidding photos and starting timer
 */
- (void)startGame
{
    [self hideAllPhotos];
    [self startTimer];
}

/**
 *  Starts timer to update time of game
 */
- (void)startTimer
{
    if (_timer == nil) {
        _startDate = [NSDate date];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                repeats:YES];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:_timer forMode:NSRunLoopCommonModes];
        [runloop addTimer:_timer forMode:UITrackingRunLoopMode];
    }
}

/**
 *  Stops timer to end updating time of game
 */
- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

/**
 * Updates time label
 */
- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_startDate];
    _endDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:_endDate];
    _timerLbl.text = timeString;
}

/**
 * Called when user exits game before ending
 */
- (void)exitGame
{
    [self stopTimer];
    [self performSegueWithIdentifier:@"mainFromGridSegue" sender:self];
}

/**
 * Called when user completes game
 */
- (void)endGame
{
    [self performSegueWithIdentifier:@"scoreFromGridSegue" sender:self];
}

/**
 * Hides all photos in grid, used when game starts
 */
- (void)hideAllPhotos
{
    // Set model data
    double delay = 0;
    for (int i=0; i < (_numOfPhotos); i++) {
        FLPGridItem *gridItem = [_photosInGrid objectAtIndex:i];
        gridItem.isShowing = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        FLPCollectionViewCell *cell = (FLPCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            [cell performSelector:@selector(flipCellToCoverAnimated:)
                       withObject:[NSNumber numberWithBool:YES]
                       afterDelay:delay
                          inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        delay += 0.1;
    }
    
    [self performSelector:@selector(setStarted:) withObject:[NSNumber numberWithBool:YES] afterDelay:delay];
}

/**
 * Crops and returns the given image to be squared
 * @param original Image to crop
 * @return Image cropped
 */
- (UIImage *)imageCrop:(UIImage*)original
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
