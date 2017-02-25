//
//  FLPNewGridViewController.m
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPNewGridViewController.h"

#import "FLPCollectionViewCell.h"

#define kFirstLookDuration 4.0f
#define kNextCellDelayDuration 0.2f

@interface FLPNewGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic, nonnull) NSArray *gridCellsModels;
@property (strong, nonatomic, nullable) NSIndexPath *flippedIndexPath;
@property (nonatomic) BOOL isUserInteractionEnabled;
@property (nonatomic) NSInteger numberOfmatchs;
@property (strong, nonatomic, nullable) NSTimer *timer;
@property (strong, nonatomic, nullable) NSDate *startDate;
@property (nonatomic) NSTimeInterval timeNotPaused;

@end

@implementation FLPNewGridViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:kReusableIdentifier bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kReusableIdentifier];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showAllUserImagesForAWhile];
}

#pragma mark - Action methods

- (IBAction)didSelectExit:(id)sender
{
    [self confirmExit];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.gridCellsModels == nil) ? 0 : self.gridCellsModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifier
                                                                            forIndexPath:indexPath];
    GridCellStatus *gridCellStatus = [self.gridCellsModels objectAtIndex:indexPath.item];
    [cell setupCell:gridCellStatus.gridCell withNumber:(indexPath.item + 1)];
    
    [cell flipToUserImageWithAnimation:@(NO) onCompletion:^{}];
    
    return cell;
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

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isUserInteractionEnabled) {
        
        GridCellStatus *selectedModel = [self.gridCellsModels objectAtIndex:indexPath.item];
        FLPCollectionViewCell *selectedCell = (FLPCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        
        if (!selectedModel.isFlipped) {
            [self flipSelectedCell:selectedCell atIndex:indexPath withModel:selectedModel];
        }
    }
}

#pragma mark - NewGridViewControllerDelegate methods

- (void)showItems:(NSArray<GridCell *> *)items
{
    self.gridCellsModels = [self createGridCellsFromItems:items];
    if (self.collectionView != nil) {
        [self.collectionView reloadData];
        [self startTimer];
    }
}

#pragma mark - Private methods

- (void)confirmExit
{
    [self pauseTimer];

    [DWPAlertController showAlertWithMessage:NSLocalizedString(@"GRID_EXIT_CONFIRM", @"")
                                       title:@""
                            firstButtonTitle:NSLocalizedString(@"OTHER_CANCEL", @"")
                           secondButtonTitle:NSLocalizedString(@"GRID_EXIT", @"")
                                  firstBlock:^{
                                      
                                      [self resumeTimer];
                                  }
                                 secondBlock:^{
                                     
                                     [self stopTimer];
                                     [self.presenterDelegate didSelectExit];
                                 }];
}

- (NSArray *)createGridCellsFromItems:(NSArray *)items
{
    NSMutableArray *gridCells = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(GridCell * _Nonnull oneItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        GridCellStatus *oneGridCell = [[GridCellStatus alloc] init];
        oneGridCell.gridCell = oneItem;
        oneGridCell.isPaired = NO;
        oneGridCell.isFlipped = NO;
        
        [gridCells addObject:oneGridCell];
        
    }];
    
    return gridCells;
}

- (void)flipSelectedCell:(FLPCollectionViewCell *)selectedCell
                 atIndex:(NSIndexPath *)indexPath
               withModel:(GridCellStatus *)selectedModel
{
    selectedModel.isFlipped = YES;
    BOOL isFirstOfTwoCells = (self.flippedIndexPath == nil);
    
    self.flippedIndexPath = (isFirstOfTwoCells) ? indexPath : self.flippedIndexPath;
    self.isUserInteractionEnabled = (isFirstOfTwoCells) ? YES : NO;

    [selectedCell flipToUserImageWithAnimation:@(YES) onCompletion:^{
        
        if (!isFirstOfTwoCells) {
            [self checkIfCellsMatchWithSelectedCell:selectedCell andModel:selectedModel];
        }
    }];
}

- (void)checkIfCellsMatchWithSelectedCell:(FLPCollectionViewCell *)selectedCell andModel:(GridCellStatus *)selectedModel
{
    GridCellStatus *flippedModel = [self.gridCellsModels objectAtIndex:self.flippedIndexPath.item];
    FLPCollectionViewCell *flippedCell = (FLPCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:self.flippedIndexPath];
    BOOL isAMatch = selectedModel.gridCell.equalIndex == self.flippedIndexPath.item;
    
    NSArray *cells = @[selectedCell, flippedCell];
    NSArray *models = @[selectedModel, flippedModel];
    
    if (isAMatch) {
        [self cellsMatch:cells withModels:models];
    } else {
        [self cellsDoesntMatch:cells withModels:models];
    }
}

- (void)cellsMatch:(NSArray *)cell withModels:(NSArray *)models
{
    FLPCollectionViewCell *selectedCell = cell[0];
    GridCellStatus *selectedModel = models[0];
    
    FLPCollectionViewCell *flippedCell = cell[1];
    GridCellStatus *flippedModel = models[1];
    
    self.flippedIndexPath = nil;
    self.isUserInteractionEnabled = NO;
    
    [selectedCell showPairedAnimation:^{
    
        selectedModel.isFlipped = YES;
        selectedModel.isPaired = YES;
    }];
    
    [flippedCell showPairedAnimation:^{
        
        flippedModel.isPaired = YES;
        self.isUserInteractionEnabled = YES;
        self.numberOfmatchs += 2;
        [self checkIfGameIsFinished];
    }];
}

- (void)cellsDoesntMatch:(NSArray *)cells withModels:(NSArray *)models
{
    FLPCollectionViewCell *selectedCell = cells[0];
    GridCellStatus *selectedModel = models[0];
    
    FLPCollectionViewCell *flippedCell = cells[1];
    GridCellStatus *flippedModel = models[1];
    
    self.isUserInteractionEnabled = NO;
    
    [selectedCell flipToCoverWithAnimation:@(YES) onCompletion:^{
        selectedModel.isFlipped = NO;
    }];
    
    [flippedCell flipToCoverWithAnimation:@(YES) onCompletion:^{
        
        flippedModel.isFlipped = NO;
        self.flippedIndexPath = nil;
        self.isUserInteractionEnabled = YES;
    }];
}

- (void)checkIfGameIsFinished
{
    BOOL isGameFinshed = self.gridCellsModels.count == self.numberOfmatchs;
    
    if (isGameFinshed) {
        
        // TODO: call presenter delegate
    }
}

- (void)startTimer
{
    self.startDate = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateTimeLabel)
                                                userInfo:nil
                                                 repeats:YES];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
}

- (void)pauseTimer
{
    NSDate *now = [NSDate date];
    NSTimeInterval elapsedTime = [now timeIntervalSinceDate:self.startDate];
    self.timeNotPaused += elapsedTime;
    
    [self stopTimer];
}

- (void)resumeTimer
{
    [self startTimer];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTimeLabel
{
    NSDate *now = [NSDate date];
    NSTimeInterval totalTime = [now timeIntervalSinceDate:self.startDate] + self.timeNotPaused;
    
    NSDate *totalDate = [NSDate dateWithTimeIntervalSince1970:totalTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *totalTimeFormatted = [dateFormatter stringFromDate:totalDate];
    
    self.timeLabel.text = totalTimeFormatted;
}

- (void)showAllUserImagesForAWhile
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kFirstLookDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hideAllUserImagesAndStartGame];
    });
}

- (void)hideAllUserImagesAndStartGame
{
    NSTimeInterval delay = 0;
    
    for (int cellIndex = 0; cellIndex < (self.gridCellsModels.count); cellIndex++) {
        [self flipCellToCoverAtIndex:cellIndex withDelay:delay];
        delay += kNextCellDelayDuration;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self gameStarts];
    });
}

- (void)gameStarts
{
    [self startTimer];
    self.isUserInteractionEnabled = YES;
}

- (void)flipCellToCoverAtIndex:(NSInteger)index withDelay:(NSTimeInterval)delay
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    FLPCollectionViewCell *cell = (FLPCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSInvocation *invocation = [self invocationToFlipCellToCover:cell];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        BOOL isLastCell = (indexPath.item == (self.gridCellsModels.count - 1));
        if (isLastCell) {
            [self startTimer];
            self.isUserInteractionEnabled = YES;
        }
        [invocation invoke];
    });
}

- (NSInvocation *)invocationToFlipCellToCover:(FLPCollectionViewCell *)cell
{
    SEL selector = NSSelectorFromString(@"flipToCoverWithAnimation:onCompletion:");
    NSNumber *animated = [NSNumber numberWithBool:YES];
    void (^completion)(void) = ^void(){};
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[cell methodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:cell];
    [invocation setArgument:&animated atIndex:2];
    [invocation setArgument:&completion atIndex:3];
    
    return invocation;
}

@end
