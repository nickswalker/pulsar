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
- (void)countDidReset;
@end

@interface Timer : NSObject

@property (weak, nonatomic) id <TimerDelegate> delegate;
@property bool on;
@property int currentBeat;
@property NSDictionary* timeSignature;
@property int bpm;


- (id) initWithDelegate:(id)sentTarget;
- (void) startTimer;
- (void) stopTimer;
- (void) beat:(NSTimer*)timer;
- (void) updateCount;

@end
