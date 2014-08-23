//
//  FLPGridItem.h
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class represents the data model and state for each item (cell) in grid
 */
@interface FLPGridItem : NSObject

// Index for this image in main images array
@property (nonatomic) NSInteger imageIndex;
// YES if this item has been matched in grid
@property (nonatomic, strong) NSNumber *isMatched;
// YES if this item is being shown in grid
@property (nonatomic, strong) NSNumber *isShowing;

@end
