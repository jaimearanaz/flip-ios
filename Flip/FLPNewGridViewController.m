//
//  FLPNewGridViewController.m
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "FLPNewGridViewController.h"

#import "FLPCollectionViewCell.h"

@interface FLPNewGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic, nonnull) NSArray *gridCellsModels;
@property (strong, nonatomic, nullable) NSIndexPath *flippedIndexPath;
@property (nonatomic) BOOL isUserInteractionEnabled;
@property (nonatomic) NSInteger numberOfmatchs;

@end

@implementation FLPNewGridViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isUserInteractionEnabled = YES;
    
    UINib *nib = [UINib nibWithNibName:kReusableIdentifier bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kReusableIdentifier];

    [self.collectionView reloadData];
}

#pragma mark - Action methods

- (IBAction)didSelectExit:(id)sender
{
    [self confirmExit];
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

#pragma mark - NewGridViewControllerDelegate methods

- (void)showItems:(NSArray<GridCell *> *)items
{
    self.gridCellsModels = [self createGridCellsFromItems:items];
    if (self.collectionView != nil) {
        [self.collectionView reloadData];
    }
}

#pragma mark - Private methods

- (void)confirmExit
{
    // TODO: stop timer

    [DWPAlertController showAlertWithMessage:NSLocalizedString(@"GRID_EXIT_CONFIRM", @"")
                                       title:@""
                            firstButtonTitle:NSLocalizedString(@"OTHER_CANCEL", @"")
                           secondButtonTitle:NSLocalizedString(@"GRID_EXIT", @"")
                                  firstBlock:^{
                                      // TODO: resume timer
                                  }
                                 secondBlock:^{
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

    [selectedCell flipToUserImageWithAnimation:YES onCompletion:^{
        
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
    
    [selectedCell flipToCoverWithAnimation:YES onCompletion:^{
        selectedModel.isFlipped = NO;
    }];
    
    [flippedCell flipToCoverWithAnimation:YES onCompletion:^{
        
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

@end
