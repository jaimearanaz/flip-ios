//
//  FLPGridViewController.h
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridPresenterDelegate;
@protocol GridViewControllerDelegate;

@interface FLPGridViewController : FLPBaseViewController <GridViewControllerDelegate>

@property (strong, nonatomic, nonnull) id<GridPresenterDelegate> presenterDelegate;

@end
