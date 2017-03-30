//
//  FLPMainViewController.h
//  Flip
//
//  Created by Jaime on 04/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLPBaseViewController.h"

@protocol MainPresenterDelegate;
@protocol MainViewControllerDelegate;

@interface FLPMainViewController : FLPBaseViewController <MainViewControllerDelegate>

- (void)setupViewController:(id<MainPresenterDelegate>)presenterDelegate;

@end
