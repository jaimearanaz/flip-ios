//
//  FLPCollectionViewCell.h
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *imageSide;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIView *coverSide;
@property (weak, nonatomic) IBOutlet UILabel *number;

- (void)setupCell:(nonnull GridCell *)gridCell withNumber:(NSInteger)position;

- (void)flipToUserImageWithAnimation:(BOOL)animated onCompletion:(nonnull void(^)())completion;

- (void)flipToCoverWithAnimation:(BOOL)animated onCompletion:(nonnull void(^)())completion;

- (void)showPairedAnimation:(nonnull void(^)())completion;

@end
