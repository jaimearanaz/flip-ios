//
//  FLPGridViewController.h
//  Flip
//
//  Created by Jaime on 24/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPGridViewController : UIViewController

// Array with original photos
@property (nonatomic, strong) NSArray *photos;

// Number of photos from |photos| to use in grid view
// Total size of grid will be |size| * 2
@property (nonatomic) NSInteger size;

@end
