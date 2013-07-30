//
//  Timer.h
//  Ticker
//
//  Created by Nick Walker on 7/19/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Timer : NSObject

@property bool on;
@property NSUInteger bpm;
@property NSUInteger beatDenomination;
- (void) startTimer;
- (void) stopTimer;
- (void) beat:(NSTimer*)timer;


@end
