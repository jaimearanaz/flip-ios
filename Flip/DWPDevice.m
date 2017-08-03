//
//  DWPDevice.m
//  Mystilo
//
//  Created by Jaime Aranaz on 01/12/15.
//  Copyright © 2015 Corpora360. All rights reserved.
//

#import "DWPDevice.h"

@implementation DWPDevice

#pragma mark - Public methods

+ (BOOL)isiPhone3_5Inches
{
    return ([UIScreen mainScreen].bounds.size.height == kiPhone3_5InchesHeight);
}

+ (BOOL)isiPhone4Inches
{
    return ([UIScreen mainScreen].bounds.size.height == kiPhone4InchesHeight);
}

+ (BOOL)isiPhone4_7Inches
{
    return ([UIScreen mainScreen].bounds.size.height == kiPhone4_7InchesHeight);
}

+ (BOOL)isiPhone5_5Inches
{
    return ([UIScreen mainScreen].bounds.size.height == kiPhone5_5InchesHeight);
}

@end
