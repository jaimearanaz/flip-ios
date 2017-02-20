//
//  FLPCollectionViewCell.m
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPCollectionViewCell.h"

@interface FLPCollectionViewCell ()

@end

@implementation FLPCollectionViewCell

#pragma mark - Public methods

- (void)setupCell:(nonnull GridCell *)gridCell withNumber:(NSInteger)position
{
    self.userImage.image = gridCell.image;
    self.number.text = [NSString stringWithFormat:@"%@", @(position)];
}

- (void)flipToUserImageWithAnimation:(BOOL)animated onCompletion:(nonnull void(^)())completion
{
    if (animated) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                                [self.contentView bringSubviewToFront:self.imageSide];
                        } completion:^(BOOL finished) {
                            completion();
                        }];
    } else {
        [self.contentView bringSubviewToFront:self.imageSide];
    }
}

- (void)flipToCoverWithAnimation:(BOOL)animated onCompletion:(nonnull void(^)())completion
{
    if (animated) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self.contentView bringSubviewToFront:self.coverSide];
                        } completion:^(BOOL finished) {
                            completion();
                        }];
    } else {
        [self.contentView bringSubviewToFront:self.coverSide];
    }
}

- (void)showPairedAnimation:(nonnull void(^)())completion
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
}

@end
