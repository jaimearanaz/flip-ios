//
//  FLPGridViewController.h
//  Flip
//
//  Created by Jaime Aranaz on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

// Types of sizes in grid
typedef enum {
    GridSizeSmall,
    GridSizeMedium,
    GridSizeBig
} GridSizeType;

/**
 * This controller represents the grid whith user's photos
 */
@interface FLPGridViewController : UIViewController

// Array with all original photos
@property (nonatomic, strong) NSArray *photos;
// Size for this grid
@property (nonatomic) GridSizeType gridSize;

@end
