//
//  FLPViewController.h
//  Flip
//
//  Created by Jaime Aranaz on 14/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <UIKit/UIKit.h>

// Used to know if user cancels Twitter web login
#define FLP_WEB_LOGIN_TWITTER_CANCELED_NOTIFICATION @"FLPWebLoginViewControllerTwitterCanceledNotification"

/**
 * This controller represents the main screen in app
 * It offers three main views to user: 
 * - records
 * - selection of source
 * - selection of grid size
 */
@interface FLPMainScrenViewController : UIViewController

// YES if controller must start showing records view, FALSE if source view instead
@property (nonatomic) BOOL startWithRecordsView;

@end
