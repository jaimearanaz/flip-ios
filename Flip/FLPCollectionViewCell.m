//
//  FLPCollectionViewCell.m
//  Flip
//
//  Created by Jaime on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPCollectionViewCell.h"

@implementation FLPCollectionViewCell

- (void)flipCellAnimated:(NSNumber *)animated
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self.contentView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            if ([self.contentView.subviews objectAtIndex:0] == _imageView) {
                                [self.contentView bringSubviewToFront:_imageView];
                            } else {
                                [self.contentView bringSubviewToFront:_coverView];
                            }
                        } completion:^(BOOL finished) {
                        }];
    } else {
        if ([self.contentView.subviews objectAtIndex:0] == _imageView) {
            [self.contentView bringSubviewToFront:_imageView];
        } else {
            [self.contentView bringSubviewToFront:_coverView];
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
