//
//  FLPViewController.h
//  Flip
//
//  Created by Jaime on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION @"FLPWebLoginViewControllerTwitterCanceledNotification"

@interface FLPMainScrenViewController : UIViewController

// YES if controller must start showing records view, FALSE if source view instead
@property (nonatomic) BOOL startWithRecordsView;

@end
