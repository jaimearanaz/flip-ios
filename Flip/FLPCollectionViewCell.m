//
//  FLPCollectionViewCell.m
//  Flip
//
//  Created by Jaime on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPCollectionViewCell.h"

@implementation FLPCollectionViewCell

- (BOOL)isShowingImage
{
    return ([self.contentView.subviews objectAtIndex:1] == _imageView);
}

- (void)flipCellAnimated:(NSNumber *)animated
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            if ([self isShowingImage]) {
                                [self.contentView bringSubviewToFront:_coverView];
                            } else {
                                [self.contentView bringSubviewToFront:_imageView];
                            }
                        } completion:^(BOOL finished) {
                        }];
    } else {
        if ([self isShowingImage]) {
            [self.contentView bringSubviewToFront:_coverView];
        } else {
            [self.contentView bringSubviewToFront:_imageView];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
