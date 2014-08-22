//
//  WE2LogFormatter.m
//  UserApp
//
//  Created by Jaime Aranaz on 28/05/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLPLogFormatter.h"

#import "DDLog.h"

@interface FLPLogFormatter()

@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSString* appName;
@property (nonatomic) int processId;

@end

@implementation FLPLogFormatter

- (id)init
{
    self = [super init];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
    
    self.appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    self.processId = [[NSProcessInfo processInfo] processIdentifier];
    
    return self;
}

/**
 *  Gives format to log messages, includig:
 * - timestamp
 * - app name
 * - process id
 * - log level
 * - log message
 *  @param logMessage log object
 *  @return string with complete log message to print
 */
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"E"; break;
        case LOG_FLAG_WARN  : logLevel = @"W"; break;
        case LOG_FLAG_INFO  : logLevel = @"I"; break;
        case LOG_FLAG_DEBUG : logLevel = @"D"; break;
        default             : logLevel = @"V"; break;
    }
    
    NSString* date = [_dateFormatter stringFromDate:logMessage->timestamp];

    return [NSString stringWithFormat:@"%@ %@[%d] %@ | %@", date, _appName, _processId, logLevel, logMessage->logMsg];
}

@end