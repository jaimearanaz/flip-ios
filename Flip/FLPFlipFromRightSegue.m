//
//  FLPFlipFromRightSegue.m
//  Flip
//
//  Created by Jaime on 17/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPFlipFromRightSegue.h"

@implementation FLPFlipFromRightSegue

- (void)perform
{
    UIViewController *sourceViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destinationViewController = (UIViewController *) self.destinationViewController;
    
    [UIView beginAnimations:@"FlipFromRight" context:nil];
    [UIView setAnimationDuration:0.65];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:sourceViewController.view.superview cache:YES];
    [UIView commitAnimations];
    
    [sourceViewController presentViewController:destinationViewController animated:NO completion:nil];
}

@end
