//
//  WE2LogFormatter.h
//  UserApp
//
//  Created by Jaime Aranaz on 28/05/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Gives format to log messages, includig:
 * - timestamp
 * - app name
 * - process id
 * - log level
 * - log message
 */
@interface FLPLogFormatter : NSObject <DDLogFormatter>

@end
