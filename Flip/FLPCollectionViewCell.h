//
//  FLPCollectionViewCell.h
//  Flip
//
//  Created by Jaime on 11/08/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *coverView;
@property (nonatomic, weak) IBOutlet UILabel *coverLbl;
@property (nonatomic) NSInteger imageIndex;
@property (nonatomic) BOOL fixed;

- (BOOL)isImageShowing;
- (void)flipCellAnimated:(NSNumber *)animated;

@end
