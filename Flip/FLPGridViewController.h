//
//  FLPGridViewController.h
//  Flip
//
//  Created by Jaime on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GridSizeSmall,
    GridSizeNormal,
    GridSizeBig
} GridSizeType;

@interface FLPGridViewController : UIViewController

// Array with all original images
@property (nonatomic, strong) NSArray *photos;
// Size for this grid
@property (nonatomic) GridSizeType gridSize;

@end
