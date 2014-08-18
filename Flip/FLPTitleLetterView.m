//
//  FLPTitleLetterView.m
//  Flip
//
//  Created by Jaime on 18/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPTitleLetterView.h"

@implementation FLPTitleLetterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (BOOL)isShowingLetter
{
    return ([self.subviews objectAtIndex:1] == _letterSide);
}

- (void)flipToLetterAnimated:(NSNumber *)animated
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self bringSubviewToFront:_letterSide];
                        } completion:^(BOOL finished) {
                        }];
    } else {
        [self bringSubviewToFront:_letterSide];
    }
}

- (void)flipToCoverAnimated:(NSNumber *)animated
{
    if ([animated boolValue]) {
        [UIView transitionWithView:self
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self bringSubviewToFront:_coverSide];
                        } completion:^(BOOL finished) {
                        }];
    } else {
        [self bringSubviewToFront:_coverSide];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {

    if ([self isShowingLetter]) {
        [self flipToCoverAnimated:[NSNumber numberWithBool:YES]];
    } else {
        [self flipToLetterAnimated:[NSNumber numberWithBool:YES]];
    }
}

@end
