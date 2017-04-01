//
//  FLPGridViewController.m
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPGridViewController.h"

#import "DWPDevice.h"
#import "FLPCollectionViewCell.h"

#define kFirstLookDuration 4.0f
#define kNextCellDelayDuration 0.2f

@interface FLPGridViewController () <GridCollectionControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic, nonnull) id<GridPresenterDelegate> presenterDelegate;
@property (strong, nonatomic, nullable) GridCollectionController *collectionViewDelegate;
@property (strong, nonatomic, nonnull) NSArray *gridCellsModels;
@property (nonatomic) GameSize gameSize;
@property (strong, nonatomic, nullable) NSIndexPath *flippedIndexPath;
@property (nonatomic) BOOL isUserInteractionEnabled;
@property (nonatomic) NSInteger numberOfMatches;
@property (nonatomic) NSInteger numberOfErrors;
@property (strong, nonatomic, nullable) NSTimer *timer;
@property (strong, nonatomic, nullable) NSDate *startDate;
@property (nonatomic) NSTimeInterval timeNotPaused;
@property (nonatomic) BOOL isStartingGame;

@end

@implementation FLPGridViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self setupCollectionViewIfReady];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self setupCollectionView];
}

#pragma mark - Public methods

- (void)setupViewController:(id<GridPresenterDelegate>)presenterDelegate
{
    self.presenterDelegate = presenterDelegate;
}

#pragma mark - Action methods

- (IBAction)didSelectExit:(id)sender
{
    [self confirmExit];
}

#pragma mark - GridCollectionControllerDelegate methods

- (void)collectionViewIsBuilt
{
    if (self.isStartingGame) {
        [self showAllUserImagesForAWhile];
        self.isStartingGame = NO;
    }
}

- (void)didSelectCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.isUserInteractionEnabled) {
        
        NSInteger index = [self indexInsideModelForIndexPath:indexPath];
        GridCellStatus *selectedModel = [self.gridCellsModels objectAtIndex:index];
        FLPCollectionViewCell *selectedCell = (FLPCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if (!selectedModel.isFlipped) {
            [self flipSelectedCell:selectedCell atIndex:indexPath withModel:selectedModel];
        }
    }
}

#pragma mark - GridViewControllerDelegate methods

- (void)showItems:(NSArray<GridCell *> *)items withSize:(GameSize)size
{
    self.gridCellsModels = [self createGridCellsFromItems:items];
    self.gameSize = size;
    self.isStartingGame = YES;
    [self resetTimeLabel];
    [self setupCollectionViewIfReady];
}

#pragma mark - Private methods

- (void)setupCollectionViewIfReady
{
    BOOL ready = ((self.collectionView != nil) && (self.gridCellsModels != nil));
    if (ready) {
        
        [self setupCollectionView];
    }
}

- (void)setupCollectionView
{
    self.collectionViewDelegate = [[GridCollectionController alloc] initWithCollectionView:self.collectionView
                                                                                       size:self.gameSize
                                                                                     models:self.gridCellsModels
                                                                             isStartingGame:self.isStartingGame
                                                                                   delegate:self];
    self.collectionView.delegate = self.collectionViewDelegate;
    self.collectionView.dataSource = self.collectionViewDelegate;
    [self.collectionView reloadData];
}

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
    NSInteger indexForFlippedItem = [self indexInsideModelForIndexPath:self.flippedIndexPath];
    GridCellStatus *flippedModel = [self.gridCellsModels objectAtIndex:indexForFlippedItem];
    FLPCollectionViewCell *flippedCell = (FLPCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:self.flippedIndexPath];

    BOOL isAMatch = selectedModel.gridCell.equalIndex == indexForFlippedItem;
    NSArray *cells = @[selectedCell, flippedCell];
    NSArray *models = @[selectedModel, flippedModel];
    
    if (isAMatch) {
        [self cellsMatch:cells withModels:models];
    } else {
        [self cellsDoesntMatch:cells withModels:models];
    }
}

- (NSInteger)indexInsideModelForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemsPerSection = [self.collectionView numberOfItemsInSection:0];
    NSInteger modelIndex = (itemsPerSection * indexPath.section) + indexPath.item;
    
    return modelIndex;
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
        self.numberOfMatches += 2;
        [self finishGameIfAllCellsMatch];
    }];
}

- (void)cellsDoesntMatch:(NSArray *)cells withModels:(NSArray *)models
{
    FLPCollectionViewCell *selectedCell = cells[0];
    GridCellStatus *selectedModel = models[0];
    
    FLPCollectionViewCell *flippedCell = cells[1];
    GridCellStatus *flippedModel = models[1];
    
    self.isUserInteractionEnabled = NO;
    self.numberOfErrors++;
    
    [selectedCell flipToCoverWithAnimation:@(YES) onCompletion:^{
        selectedModel.isFlipped = NO;
    }];
    
    [flippedCell flipToCoverWithAnimation:@(YES) onCompletion:^{
        
        flippedModel.isFlipped = NO;
        self.flippedIndexPath = nil;
        self.isUserInteractionEnabled = YES;
    }];
}

- (void)finishGameIfAllCellsMatch
{
    BOOL isGameFinshed = self.gridCellsModels.count == self.numberOfMatches;
    
    if (isGameFinshed) {
    
        [self stopTimer];
        NSDate *now = [NSDate date];
        NSTimeInterval totalTime = [now timeIntervalSinceDate:self.startDate] + self.timeNotPaused;
        
        [self.presenterDelegate gameFinishedWithTime:totalTime numberOfErrors:self.numberOfErrors];
    }
}

- (void)startTimer
{
    self.startDate = [NSDate date];
    self.timeNotPaused = 0;
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
    if (self.timer != nil) {
        
        NSDate *now = [NSDate date];
        NSTimeInterval totalTime = [now timeIntervalSinceDate:self.startDate] + self.timeNotPaused;
        
        NSDate *totalDate = [NSDate dateWithTimeIntervalSince1970:totalTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
        NSString *totalTimeFormatted = [dateFormatter stringFromDate:totalDate];
        
        self.timeLabel.text = totalTimeFormatted;
    }
}

- (void)resetTimeLabel
{
    self.timeLabel.text = @"00:00";
}

- (void)showAllUserImagesForAWhile
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kFirstLookDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hideAllUserImagesAndStartGame];
    });
}

// TODO: bug, last images are flipped simultaneously
- (void)hideAllUserImagesAndStartGame
{
    NSTimeInterval delay = 0;
    NSInteger numOfSections = [self.collectionView numberOfSections];
    
    for (int oneSection = 0; oneSection < numOfSections; oneSection++) {
        
        NSInteger numOfItems = [self.collectionView numberOfItemsInSection:oneSection];
        
        for (int oneItem = 0; oneItem < numOfItems; oneItem++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:oneItem inSection:oneSection];
            [self flipCellToCoverAtIndex:indexPath withDelay:delay];
            delay += kNextCellDelayDuration;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self gameStarts];
    });
}

- (void)gameStarts
{
    [self startTimer];
    self.isUserInteractionEnabled = YES;
    self.numberOfErrors = 0;
    self.numberOfMatches = 0;
}

- (void)flipCellToCoverAtIndex:(NSIndexPath *)indexPath withDelay:(NSTimeInterval)delay
{
    FLPCollectionViewCell *cell = (FLPCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSInvocation *invocation = [self invocationToFlipCellToCover:cell];
    NSInteger numOfSections = [self.collectionView numberOfSections];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSInteger indexInModel = [self indexInsideModelForIndexPath:indexPath];
        BOOL isLastCell = ((indexPath.section == (numOfSections - 1)) && ((self.gridCellsModels.count - 1) == indexInModel));
        if (isLastCell) {
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
