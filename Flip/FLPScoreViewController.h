//
//  FLPScoreViewController.h
//  Flip
//
//  Created by Jaime on 12/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLPGridViewController.h"

@interface FLPScoreViewController : UIViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic) NSInteger numOfErrors;
@property (nonatomic) GridSizeType gridSize;

@end
