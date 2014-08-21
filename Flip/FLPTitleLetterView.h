//
//  FLPTitleLetterView2.h
//  Flip
//
//  Created by Jaime on 21/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPTitleLetterView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *letterSide;
@property (nonatomic, weak) IBOutlet UIImageView *coverSide;

- (void)flipAnimated:(NSNumber *)animated;

@end