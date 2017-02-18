//
//  PPJAlertController.m
//  Mystilo
//
//  Created by Jaime Aranaz on 27/02/15.
//  Copyright (c) 2015 Corpora360. All rights reserved.
//

#import "DWPAlertController.h"

@implementation DWPAlertController

#pragma mark - Public methods

+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title completionBlock:(void (^)(void))completion
{
    NSString *action = NSLocalizedString(@"ACCEPT", @"Accept button");

    SDCAlertController *alert = [[SDCAlertController alloc] initWithTitle:title
                                                                  message:message
                                                           preferredStyle:SDCAlertControllerStyleAlert];
    
    [alert add:[[SDCAlertAction alloc] initWithTitle:action
                                               style:SDCAlertActionStyleNormal
                                             handler:^(SDCAlertAction * _Nonnull action) {
                                                 if (completion) {
                                                     completion();
                                                 }
                                             }]];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [alert presentAnimated:YES completion:nil];
    });
}

+ (void)showAlertWithMessage:(NSString *)message
                       title:(NSString *)title
            firstButtonTitle:(NSString *)firstTitle
           secondButtonTitle:(NSString *)secondTitle
                  firstBlock:(void (^)(void))firstBlock
                 secondBlock:(void (^)(void))secondBlock
{
    SDCAlertController *alert = [[SDCAlertController alloc] initWithTitle:title
                                                                  message:message
                                                           preferredStyle:SDCAlertControllerStyleAlert];

    [alert add:[[SDCAlertAction alloc] initWithTitle:firstTitle
                                               style:SDCAlertActionStyleNormal
                                             handler:^(SDCAlertAction * _Nonnull action) {
                                                 if (firstBlock) {
                                                     firstBlock();
                                                 }
                                             }]];
    
    
    [alert add:[[SDCAlertAction alloc] initWithTitle:secondTitle
                                               style:SDCAlertActionStyleNormal
                                             handler:^(SDCAlertAction * _Nonnull action) {
                                                 if (secondBlock) {
                                                     secondBlock();
                                                 }
                                             }]];

    dispatch_async(dispatch_get_main_queue(), ^(void){
        [alert presentAnimated:YES completion:nil];
    });
}

@end
