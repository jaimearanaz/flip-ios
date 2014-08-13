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

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *coverView;
@property (nonatomic, weak) IBOutlet UILabel *coverLbl;

/**
 * Flips cell to show image
 * @param animated YES to animate transition, NO otherwise
 */
- (void)flipCellToImageAnimated:(NSNumber *)animated;

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

@end
