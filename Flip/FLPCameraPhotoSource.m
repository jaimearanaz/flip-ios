//
//  FLPCameraPhotoSource.m
//  Flip
//
//  Created by Jaime on 23/07/14.
//  Copyright (c) 2014 MobiOak. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "FLPCameraPhotoSource.h"

@implementation FLPCameraPhotoSource

- (NSArray *)getPhotosFromSource:(NSInteger)number
{
    NSMutableArray __block *photos = [[NSMutableArray alloc] init];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSInteger __block numberOfPhotos = number;
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (group != nil) {
                                         
                                         // Get photos only
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         // Set range
                                         numberOfPhotos = (group.numberOfAssets < number) ? group.numberOfAssets  : number;
                                         NSRange range = NSMakeRange(0, numberOfPhotos - 1);
                                         
                                         // Enumerate all photos in current group
                                         [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]
                                                                 options:0
                                                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                  if (result != nil) {
                                                                      
                                                                      // TODO: maybe thumbnail is better instead defaultRepresentation?
                                                                      ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                      UIImage *image = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                                                                      // Add image
                                                                      [photos addObject:image];
                                                                      
                                                                      *stop = (photos.count == numberOfPhotos) ? YES : NO;
                                                                  }
                                                              }];
                                     }
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                 }];
    
    return photos;
}

@end
