//
//  FLPTitleLetterView.h
//  Flip
//
//  Created by Jaime on 18/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPTitleLetterView : UIView

@property (nonatomic, weak) IBOutlet UIView *letterSide;
@property (nonatomic, weak) IBOutlet UIView *coverSide;

- (BOOL)isShowingLetter;
- (void)flipToLetterAnimated:(NSNumber *)animated;
- (void)flipToCoverAnimated:(NSNumber *)animated;
- (void)flipAnimated:(NSNumber *)animated;

@end
