//
//  Timer.h
//  Ticker
//
//  Created by Nick Walker on 7/19/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Timer;
@protocol TimerDelegate

- (void)beat;

@end

@interface Timer : NSObject

@property (weak, nonatomic) id <TimerDelegate> delegate;
@property bool on;
@property int count;
@property int topSignature;
@property int bottomSignature;

- (id) initWithDelegate:(id)sentTarget;
- (void) changeSignature:(int)top and:(int)bottom;
- (void) startTimer;
- (void) stopTimer;
- (void) changeBpm:(int)value;
- (void) beat:(NSTimer*)timer;
- (void) updateCount;

@end
