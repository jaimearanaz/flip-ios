//
//  FLPScoreViewController.h
//  Flip
//
//  Created by Jaime Aranaz on 12/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLPGridViewController.h"

/**
 * This controller represent the score screen after game is completed
 */
@interface FLPScoreViewController : UIViewController

// Photos in grid, used when user tries again
@property (nonatomic, strong) NSArray *photos;
// Size of grid, used when user tries again
@property (nonatomic) GridSizeType gridSize;
// Time spent by user in the game
@property (nonatomic, strong) NSDate *time;
// Number of errors in the game
@property (nonatomic) NSInteger numOfErrors;

@end
