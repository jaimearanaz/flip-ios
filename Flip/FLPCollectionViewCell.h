//
//  FLPCollectionViewCell.h
//  Flip
//
//  Created by Jaime on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class represents a cell in grid.
 * It's build up with to "sides": image and a cover with a number. User flips between two sides when touches.
 */
@interface FLPCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView *imageSide;
@property (nonatomic, weak) IBOutlet UIView *coverSide;
@property (nonatomic, weak) IBOutlet UIImageView *photoView;
@property (nonatomic, weak) IBOutlet UILabel *coverLbl;

// TODO: comment
- (void)flipCellToImageAnimated:(NSNumber *)animated onCompletion:(void(^)())completion;

/**
 * Flips cell to show cover
 * @param animated YES to animate transition, NO otherwise
 */
- (void)flipCellToCoverAnimated:(NSNumber *)animated;

/**
 * Checks if cell is showing image or not
 * @return YES if cell is showing image, NO otherwise
 */
- (BOOL)isShowingImage;

- (void)matchedAnimation;

@end
