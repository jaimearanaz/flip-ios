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

@property (strong, nonatomic, nonnull) NSArray *gridCells;

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

#pragma mark - Action methods

- (IBAction)didSelectExit:(id)sender
{
    [self confirmExit];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: implement
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.gridCells == nil) ? 0 : self.gridCells.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    FLPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifier
                                                                            forIndexPath:indexPath];
    GridCellStatus *gridCellStatus = [self.gridCells objectAtIndex:indexPath.item];
    [cell setupCell:gridCellStatus.gridCell withPosition:indexPath.item];
    
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
    self.gridCells = [self createGridCellsFromItems:items];
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

@end
