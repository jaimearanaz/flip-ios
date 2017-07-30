//
//  FLPCollectionViewCell.m
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPCollectionViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface FLPCollectionViewCell ()

@end

@implementation FLPCollectionViewCell

#pragma mark - Public methods

- (void)setupCellWithModel:(nonnull GridCell *)gridCell andNumber:(NSInteger)position;
{
    BOOL isUrl = (gridCell.imageUrl && [gridCell.imageUrl compare:@""] != NSOrderedSame);
    BOOL isImage = (gridCell.image != nil);
    
    if (isUrl) {
        NSURL *url = [NSURL URLWithString:gridCell.imageUrl];
        [self.userImage sd_setImageWithURL:url];
    } else if (isImage) {
        [self.userImage setImage:gridCell.image];
    }
    
    self.number.text = [NSString stringWithFormat:@"%@", @(position)];
}

- (void)flipToUserImageWithAnimation:(nonnull NSNumber *)animated onCompletion:(nullable void(^)())completion
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                                [self.contentView bringSubviewToFront:self.imageSide];
                        } completion:^(BOOL finished) {
                            if (completion) {
                                completion();
                            }
                        }];
    } else {
        [self.contentView bringSubviewToFront:self.imageSide];
    }
}

- (void)flipToCoverWithAnimation:(nonnull NSNumber *)animated onCompletion:(nullable void(^)())completion
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self.contentView bringSubviewToFront:self.coverSide];
                        } completion:^(BOOL finished) {
                            if (completion) {
                                completion();
                            }
                        }];
    } else {
        [self.contentView bringSubviewToFront:self.coverSide];
    }
}

- (void)showPairedAnimation:(nullable void(^)())completion
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

@end
