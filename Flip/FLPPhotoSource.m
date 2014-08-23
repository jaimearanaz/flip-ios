//
//  FLPPhotoSource.m
//  Flip
//
//  Created by Jaime Aranaz on 16/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import "FLPPhotoSource.h"

@interface FLPPhotoSource()

@property (nonatomic, strong) NSString *cacheFileName;

@end

@implementation FLPPhotoSource

- (id)initInternetRequired:(BOOL)internetRequired cacheName:(NSString *)cacheFilename
{
    self = [super init];
    if (self) {
        self.internetRequired = internetRequired;
        self.cacheFileName = cacheFilename;
    }
    return self;
}

- (void)getPhotosFromSource:(NSInteger)number succesBlock:(void(^)(NSArray* photos))success failureBlock:(void(^)(NSError *error))failure
{
    failure([NSError errorWithDomain:@"" code:0 userInfo:nil]);
}

- (void)savePhotosToCache:(NSArray *)photos
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSInteger index = 0;
    for (UIImage *image in photos) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld", _cacheFileName, index];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        FLPLogDebug(@"saving to disk %@", fileName);
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        index++;
    }
}

- (BOOL)hasPhotosInCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@_0", _cacheFileName];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    return (image != nil);
}

- (void)getPhotosFromCacheFinishBlock:(void(^)(NSArray* photos))finish
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    NSInteger index = 0;
    NSString *fileName = [NSString stringWithFormat:@"%@_0", _cacheFileName];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    // Load image one by one
    while (image != nil) {
        FLPLogDebug(@"loading from disk %@", fileName);
        [photos addObject:image];
        index++;
        fileName = [NSString stringWithFormat:@"%@_%ld", _cacheFileName, index];
        filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    
    // Sort randomly before execute block
    finish([self sortRandomlyArray:photos]);
}

- (void)deleteCache;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    BOOL success = YES;
    NSInteger index = 0;
    NSError *error;
    while (success) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld", _cacheFileName, index];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            FLPLogDebug(@"deleting from disk %@", fileName);
        }
        index++;
    }
}

#pragma mark - Private methods

/**
 *  Sorts the given array randomly
 *  @param array Array to sort randomly
 *  @return The given array sorted randomly
 */
- (NSMutableArray *)sortRandomlyArray:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger numElements = count - i;
        NSUInteger n = (arc4random() % numElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return array;
}

@end
