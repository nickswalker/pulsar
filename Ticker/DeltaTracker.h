//
//  timeBetween.h
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeltaTracker : NSObject
@property double startTime;
@property double endTime;

- (double)benchmark;
- (void)clear;
@end
