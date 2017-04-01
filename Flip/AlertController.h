//
//  PPJAlertController.h
//  Mystilo
//
//  Created by Jaime Aranaz on 27/02/15.
//  Copyright (c) 2015 Corpora360. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AlertControllerCompletion)();

@import SDCAlertView;

@interface AlertController : NSObject

+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title completionBlock:(void (^)(void))completion;

+ (void)showAlertWithMessage:(NSString *)message
                       title:(NSString *)title
            firstButtonTitle:(NSString *)firstTitle
           secondButtonTitle:(NSString *)secondTitle
                  firstBlock:(void (^)(void))firstBlock
                 secondBlock:(void (^)(void))secondBlock;

+ (void)showActionSheetWithMessage:(NSString *)message
                             title:(NSString *)title
                     optionsTitles:(NSArray *)optionsTitles
                     optionsBlocks:(NSArray *)optionsBlocks
                       cancelTitle:(NSString *)cancelTitle
                       cancelBlock:(AlertControllerCompletion)cancelBlock;

@end
