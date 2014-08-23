//
//  FLPTitleLetterView2.h
//  Flip
//
//  Created by Jaime Aranaz on 21/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class represents a single letter in the header logo, in main screen
 * Each letter has a cover side, and users flips between them when touches
 */
@interface FLPTitleLetterView : UIView

// Side with the letter
@property (nonatomic, weak) IBOutlet UIImageView *letterSide;
// Side with the cover
@property (nonatomic, weak) IBOutlet UIImageView *coverSide;

/**
 * Flips letter between letter side and cover side when user touches
 * @param animated YES if flip is animated, NO otherwise
 */
- (void)flipAnimated:(NSNumber *)animated;

@end