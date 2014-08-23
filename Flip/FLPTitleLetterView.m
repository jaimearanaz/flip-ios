//
//  FLPTitleLetterView2.m
//  Flip
//
//  Created by Jaime Aranaz on 21/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPTitleLetterView.h"

@implementation FLPTitleLetterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleSingleTap:)];
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

- (void)flipAnimated:(NSNumber *)animated
{
    if ([self isShowingLetter]) {
        [self flipToCoverAnimated:animated];
    } else {
        [self flipToLetterAnimated:animated];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self flipAnimated:[NSNumber numberWithBool:YES]];
}

@end
