//
//  PPJAlertController.m
//  Mystilo
//
//  Created by Jaime Aranaz on 27/02/15.
//  Copyright (c) 2015 Corpora360. All rights reserved.
//

#import "AlertController.h"

@implementation AlertController

#pragma mark - Public methods

+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title completionBlock:(void (^)(void))completion
{
    NSString *action = NSLocalizedString(@"OTHER_OK", @"Accept button");

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
                                               style:SDCAlertActionStylePreferred
                                             handler:^(SDCAlertAction * _Nonnull action) {
                                                 if (secondBlock) {
                                                     secondBlock();
                                                 }
                                             }]];

    dispatch_async(dispatch_get_main_queue(), ^(void){
        [alert presentAnimated:YES completion:nil];
    });
}

+ (void)showActionSheetWithMessage:(NSString *)message
                             title:(NSString *)title
                     optionsTitles:(NSArray *)optionsTitles
                     optionsBlocks:(NSArray *)optionsBlocks
                       cancelTitle:(NSString *)cancelTitle
                       cancelBlock:(AlertControllerSheetCancelCompletion)cancelBlock

{
    if (optionsTitles.count != optionsBlocks.count) {
        return;
    }
    
    SDCAlertController *alert = [[SDCAlertController alloc] initWithTitle:title
                                                                  message:message
                                                           preferredStyle:SDCAlertControllerStyleActionSheet];
    
    [alert add:[[SDCAlertAction alloc] initWithTitle:cancelTitle
                                               style:SDCAlertActionStyleDestructive
                                             handler:^(SDCAlertAction * _Nonnull action) {
                                                 
                                                 if (cancelBlock) {
                                                     cancelBlock();
                                                 }
                                             }]];
    
    for (int i = 0; i < optionsTitles.count; i++) {
        
        [alert add:[[SDCAlertAction alloc] initWithTitle:optionsTitles[i]
                                                   style:SDCAlertActionStyleNormal
                                                 handler:^(SDCAlertAction * _Nonnull action) {
                                                     
                                                    AlertControllerSheetOptionCompletion completion = optionsBlocks[i];
                                                    completion(i);
                                                 }]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [alert presentAnimated:YES completion:nil];
    });
}

@end
