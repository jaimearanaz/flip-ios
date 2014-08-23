//
//  FLPCollectionViewCell.h
//  Flip
//
//  Created by Jaime Aranaz on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class represents a single cell inside the collection view, in the grid screen.
 * It's build up with to "sides": a user's image and a cover with a number. User flips between two sides when touches.
 */
@interface FLPCollectionViewCell : UICollectionViewCell

// Cell side with the user image
@property (nonatomic, weak) IBOutlet UIView *imageSide;
// Cell side with the numbered cover
@property (nonatomic, weak) IBOutlet UIView *coverSide;
// Image object inside |imageSide|
@property (nonatomic, weak) IBOutlet UIImageView *photoView;
// Number inside |coverSide|
@property (nonatomic, weak) IBOutlet UILabel *coverLbl;

/**
 *  Flips cell to show user image
 *  @param animated   YES to animate transition, NO otherwise
 *  @param completion Block to execute when animation is complete
 */
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

/**
 * Starts a silly fade animation to use when two images are matched
 */
- (void)matchedAnimation;

@end
