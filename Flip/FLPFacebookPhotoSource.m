//
//  FLPFacebookPhotoSource.m
//  Flip
//
//  Created by Jaime on 29/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "FLPFacebookPhotoSource.h"

@interface FLPFacebookPhotoSource()

@end

@implementation FLPFacebookPhotoSource

- (id)init
{
    self = [super initInternetRequired:YES cacheName:@"facebook"];
    return self;
}

- (void)getPhotosFromSource:(NSInteger)number
                succesBlock:(void(^)(NSArray* photos))success
               failureBlock:(void(^)(NSError *error))failure
{
    FLPLogDebug(@"");
    
    // Steps:
    // 1. get all photo URLs where user is tagged
    // 2. get all photos URLs uploaded by user
    // 3. get random photo URLs betweeb tagged and uploaded
    // 4. download photos

    // 1. get all photo URLs where user is tagged
    [self getPhotosUrlFromFacebookPath:@"me/photos"
                                     limit:10
                                     offset:0
                                succesBlock:^(NSDictionary *taggedPhotos) {
                                    
                                    // 2. get all photos URLs uploaded by user
                                    [self getPhotosUrlFromFacebookPath:@"me/photos/uploaded"
                                                                 limit:10
                                                                offset:0
                                                           succesBlock:^(NSDictionary *uploadedPhotos) {
                                                               
                                                               // There are enough photos
                                                               if ((taggedPhotos.count + uploadedPhotos.count) >= number) {
                                                                   
                                                                   // 3. get random photo URLs between tagged and uploaded
                                                                   NSArray *randomPhotos = [self selectPhotos:number
                                                                                                   fromTagged:taggedPhotos
                                                                                                  andUploaded:uploadedPhotos];
                                                                   
                                                                   // 4. download photos
                                                                   NSArray *downloadedPhotos = [self downloadPhotosFromUrls:randomPhotos];
                                                                   
                                                                   if (downloadedPhotos.count < number) {
                                                                       failure([NSError errorWithDomain:@""
                                                                                                   code:kErrorDownloadingPhotos
                                                                                               userInfo:nil]);
                                                                   } else {
                                                                       success(downloadedPhotos);
                                                                   }
                                                                   
                                                               // There are no enough photos on Facebook
                                                               } else {
                                                                   failure([NSError errorWithDomain:@""
                                                                                               code:KErrorEnoughPhotos
                                                                                           userInfo:nil]);
                                                               }
                                                           }
                                                          failureBlock:^(NSError *error) {
                                                              FLPLogDebug(@"error: %@", [error localizedDescription]);
                                                              failure([NSError errorWithDomain:@""
                                                                                          code:kErrorDownloadingPhotos
                                                                                      userInfo:nil]);
                                                          }];
                                }
                               failureBlock:^(NSError *error) {
                                   FLPLogDebug(@"error: %@", [error localizedDescription]);
                                   failure([NSError errorWithDomain:@""
                                                               code:kErrorDownloadingPhotos
                                                           userInfo:nil]);
                               }];
}

#pragma mark - Private methods

- (void)getPhotosUrlFromFacebookPath:(NSString *)path
                               limit:(NSInteger)limit
                              offset:(NSInteger)offset
                         succesBlock:(void(^)(NSDictionary* photos))success
                        failureBlock:(void(^)(NSError *error))failure
{
    NSMutableDictionary *paginatedPhotos = [[NSMutableDictionary alloc] init];
    NSString *requestPath = [NSString stringWithFormat:@"%@?limit=%ld&offset=%ld", path, (long)limit, (long)offset];
    FLPLogDebug(@"calling Facebook API %@", requestPath);
    
    // Launch request
    [[FBRequest requestForGraphPath:requestPath] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSArray* data=[result objectForKey:@"data"];
        
        // Loop through images
        for (FBGraphObject* graphObject in data) {
            
            NSArray *images = [graphObject objectForKey:@"images"];
            
            // Loop through different sizes for this image
            for (FBGraphObject* imageObject in images) {
                    NSString *width = [imageObject objectForKey:@"width"];
                
                    // Add immages with width between 300 and 600 pixels
                    if ((300 < [width integerValue]) && ([width integerValue] < 600)) {
                        FLPLogDebug(@"add photo id %@ width %@ source %@",
                                    [graphObject objectForKey:@"id"],
                                    width,
                                    [imageObject objectForKey:@"source"]);
                        [paginatedPhotos setValue:[imageObject objectForKey:@"source"] forKey:[graphObject objectForKey:@"id"]];
                        break;
                    }
            }
        }
        
        // More result pending, call itself again and add current photos
        if (result[@"paging"][@"next"] != nil) {
            [self getPhotosUrlFromFacebookPath:path
                                         limit:limit
                                        offset:(offset + limit)
                                   succesBlock:^(NSDictionary *photos) {
                                            [paginatedPhotos setValuesForKeysWithDictionary:photos];
                                            success(paginatedPhotos);
                                        }
                                  failureBlock:failure];
            
        // No more results, run success block
        } else {
            success(paginatedPhotos);
        }
    }];
    
}

/**
 *  Selects random photos between given tagged and uploaded ones.
 *  @param number   Number of photos to select. If tagged and uploaded aren't enough, returns all of them.
 *  @param tagged   List of tagged
 *  @param uploaded List of uploaded photos
 *  @return Selected random photos between tagged and uploaded
 */
- (NSArray *)selectPhotos:(NSInteger)number fromTagged:(NSDictionary *)tagged andUploaded:(NSDictionary *)uploaded
{
    // Join tagged and uploaded photos
    NSMutableDictionary *allPhotos = [[NSMutableDictionary alloc] init];
    [allPhotos setValuesForKeysWithDictionary:uploaded];
    [allPhotos setValuesForKeysWithDictionary:tagged];
    
    NSMutableArray *allUrls = [NSMutableArray arrayWithArray:[allPhotos allValues]];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // Tagged and uploaded photos aren't enough, return all of them
    if (allUrls.count < number) {
        [result addObjectsFromArray:allUrls];
        FLPLogDebug(@"not enough photos, return all");
        
    // Select randomly photos
    } else {
        for (int i = 0; i < number; i++) {
            NSInteger randomIndex = arc4random() % allUrls.count;
            [result addObject:[allUrls objectAtIndex:randomIndex]];
            [allUrls removeObjectAtIndex:randomIndex];
            FLPLogDebug(@"add random %ld photo URL %@", (long)randomIndex, [allUrls objectAtIndex:randomIndex]);
        }
    }
    
    return result;
}

/**
 *  Downloads photos from given array of URLs
 *  @param users URLs to download photos
 *  @return An array of UIImages with photos
 */
- (NSArray *)downloadPhotosFromUrls:(NSArray *)urls
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (NSString *url in urls) {
        FLPLogDebug(@"download Facebook photo: %@", url);

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                    cachePolicy:NSURLCacheStorageAllowed
                                                timeoutInterval:10];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [photos addObject:image];
        } else {
            FLPLogDebug(@"error downloading: %@", [error localizedDescription]);
        }
    }
    
    return photos;
}

@end
