//
//  FLPCollectionViewCell.h
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFLPCollectionViewCellIdentifier @"FLPCollectionViewCell"

@class GridCell;

@interface FLPCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *imageSide;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIView *coverSide;
@property (weak, nonatomic) IBOutlet UILabel *number;

- (void)setupCellWithModel:(nonnull GridCell *)gridCell andNumber:(NSInteger)position;

- (void)flipToUserImageWithAnimation:(nonnull NSNumber *)animated onCompletion:(nullable void(^)())completion;

- (void)flipToCoverWithAnimation:(nonnull NSNumber *)animated onCompletion:(nullable void(^)())completion;

- (void)showPairedAnimation:(nullable void(^)())completion;

@end
