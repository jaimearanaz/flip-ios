//
//  NSArray+Extras.m
//  Flip
//
//  Created by Jaime on 17/07/2017.
//  Copyright © 2017 MobiOak. All rights reserved.
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

- (NSArray *)selectRandom:(NSInteger)number
{
    NSMutableArray *mutable = [NSMutableArray arrayWithArray:self];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    BOOL hasEnoughUsers = (mutable.count > number);
    
    if (hasEnoughUsers) {
        
        for (int i = 0; i < number; i++) {
            NSInteger randomIndex = arc4random() % mutable.count;
            [result addObject:[mutable objectAtIndex:randomIndex]];
            [mutable removeObjectAtIndex:randomIndex];
        }
        
    } else {
        
        [result addObjectsFromArray:mutable];
    }
    
    return result;
}

@end
