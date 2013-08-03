//
//  Timer.h
//  Ticker
//
//  Created by Nick Walker on 7/19/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeltaTracker.h"
@interface Timer : NSObject

typedef enum{
	half,
	quarter,
	eigth,
	sixteenth,
	dottedQuarter,
	dottedEigth
}  BeatDenomination;

@property DeltaTracker* tracker;
@property bool on;
@property NSUInteger beatPartCount;
@property NSUInteger bpm;
@property NSArray* timeSignature;
@property BeatDenomination beatDenomination;
//Type def enum ? half quarter dottedQuarter sixteenth
//Make the timer always run on the smallest possible division, allow the  other classes to determine what to show in the UI

- (void) startTimer;
- (void) stopTimer;
- (void) beat:(NSTimer*)timer;


@end
