//
//  FLPCoverFromRightSegue.m
//  Flip
//
//  Created by Jaime on 17/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPCoverFromRightSegue.h"

@implementation FLPCoverFromRightSegue

-(void)perform
{
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect frame = sourceViewController.view.frame;
                         frame.origin.x = -320;
                         [sourceViewController.view setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                         [destinationController.view.layer addAnimation:transition forKey:kCATransition];
                         [sourceViewController presentViewController:destinationController animated:NO completion:nil];
                     }];
}

@end
