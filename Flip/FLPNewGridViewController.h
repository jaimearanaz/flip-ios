//
//  FLPNewGridViewController.h
//  Flip
//
//  Created by Jaime on 17/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridPresenterDelegate;
@protocol NewGridViewControllerDelegate;

@interface FLPNewGridViewController : FLPBaseViewController <NewGridViewControllerDelegate>

@property (strong, nonatomic, nonnull) id<GridPresenterDelegate> presenterDelegate;

@end
