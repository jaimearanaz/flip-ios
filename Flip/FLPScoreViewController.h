//
//  FLPScoreViewController.h
//  Flip
//
//  Created by Jaime on 25/03/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScorePresenterDelegate;
@protocol ScoreViewControllerDelegate;

@interface FLPScoreViewController : FLPBaseViewController <ScoreViewControllerDelegate>

@property (strong, nonatomic, nonnull) id<ScorePresenterDelegate> presenterDelegate;

@end
