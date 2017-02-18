//
//  PPJAlertController.h
//  Mystilo
//
//  Created by Jaime Aranaz on 27/02/15.
//  Copyright (c) 2015 Corpora360. All rights reserved.
//

#import <Foundation/Foundation.h>

@import SDCAlertView;

// Builds and shows alert messages
@interface DWPAlertController : NSObject

// Shows an alert with the given title, message and executes given block when user presses localized ACCEPT buttom
+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title completionBlock:(void (^)(void))completion;

// Shows an alert with the given, title, message and custom buttons, and executes blocks according user answer
+ (void)showAlertWithMessage:(NSString *)message
                       title:(NSString *)title
            firstButtonTitle:(NSString *)firstTitle
           secondButtonTitle:(NSString *)secondTitle
                  firstBlock:(void (^)(void))firstBlock
                 secondBlock:(void (^)(void))secondBlock;

@end
