//
//  FLPNewGridViewController.m
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPNewGridViewController.h"

#import "DWPDevice.h"
#import "FLPCollectionViewCell.h"

#define kFirstLookDuration 4.0f
#define kNextCellDelayDuration 0.2f

@interface FLPNewGridViewController () <GridCollectionViewBuilderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic, nullable) GridCollectionViewBuilder *collectionViewDelegate;
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

@implementation FLPNewGridViewController

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

#pragma mark - Action methods

- (IBAction)didSelectExit:(id)sender
{
    [self confirmExit];
}

#pragma mark - GridCollectionViewBuilderDelegate methods

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
        
        GridCellStatus *selectedModel = [self.gridCellsModels objectAtIndex:indexPath.item];
        FLPCollectionViewCell *selectedCell = (FLPCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if (!selectedModel.isFlipped) {
            [self flipSelectedCell:selectedCell atIndex:indexPath withModel:selectedModel];
        }
    }
}

#pragma mark - NewGridViewControllerDelegate methods

- (void)showItems:(NSArray<GridCell *> *)items withSize:(GameSize)size
{
    self.gridCellsModels = [self createGridCellsFromItems:items];
    self.gameSize = size;
    self.isStartingGame = YES;
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
    self.collectionViewDelegate = [[GridCollectionViewBuilder alloc] initWithCollectionView:self.collectionView
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
        
        [self.presenterDelegate gameFinishedWithTime:totalTime numberOferrors:self.numberOfErrors];
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
