//
//  FLPCollectionViewCell.m
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPCollectionViewCell.h"

@implementation FLPCollectionViewCell

- (BOOL)isShowingImage
{
    return ([self.contentView.subviews objectAtIndex:1] == _imageSide);
}

- (void)flipCellToImageAnimated:(NSNumber *)animated onCompletion:(void(^)())completion
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                                [self.contentView bringSubviewToFront:_imageSide];
                        } completion:^(BOOL finished) {
                            if (completion) {
                                completion();
                            }
                        }];
    } else {
        [self.contentView bringSubviewToFront:_imageSide];
    }
}

- (void)flipCellToCoverAnimated:(NSNumber *)animated
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self.contentView bringSubviewToFront:_coverSide];
                        } completion:^(BOOL finished) {
                        }];
    } else {
        [self.contentView bringSubviewToFront:_coverSide];
    }
}

- (void)matchedAnimation
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
