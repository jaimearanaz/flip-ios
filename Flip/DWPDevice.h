//
//  DWPDevice.h
//  Mystilo
//
//  Created by Jaime Aranaz on 01/12/15.
//  Copyright © 2015 Corpora360. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kiPhone3_5InchesHeight 480.0f
#define kiPhone3_5InchesWidth 320.0f
#define kiPhone4InchesHeight 568.0f
#define kiPhone4InchesWidth 320.0f
#define kiPhone4_7InchesHeight 667.0f
#define kiPhone4_7InchesWidth 375.0f
#define kiPhone5_5InchesHeight 736.0f
#define kiPhone5_5InchesWidth 414.0f

// Class to checks device model
@interface DWPDevice : NSObject

// Return YES if current device is iPhone 4 or 4S
+ (BOOL)isiPhone3_5Inches;

// Return YES if current device is iPhone 5 or 5S
+ (BOOL)isiPhone4Inches;

// Return YES if current device is iPhone 6, 6S or 7
+ (BOOL)isiPhone4_7Inches;

// Return YES if current device is iPhone 6 Plus, 6S Plus or 7 Plus
+ (BOOL)isiPhone5_5Inches;

@end
