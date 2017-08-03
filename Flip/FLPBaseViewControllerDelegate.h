//
//  FLPBaseViewControllerDelegate.h
//  Flip
//
//  Created by Jaime on 05/02/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FLPBaseViewControllerDelegate <NSObject>

@property (strong, nonatomic, nonnull) UIViewController *viewController;

@end
