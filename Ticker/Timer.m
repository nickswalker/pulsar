//
//  Timer.m
//  Ticker
//
//  Created by Nick Walker on 7/19/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Timer.h"
#define SECONDS 60
@implementation Timer

@synthesize bpm = _bpm,
	on = _on;

NSTimer* timer;
id target;

-(void)startTimer{
	[timer invalidate];
	timer = nil;
	//Fire the first beat as soon as the action is registered so as to allow instant metronome start
	[self beat:nil];
	double speed = ((double)SECONDS)/self.bpm;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)stopTimer{
	[timer invalidate];
	double speed = INFINITY;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)beat:(NSTimer*)timer{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"beat" object:self];
	
}

#pragma mark - Getters and Setters

-(void)setBpm:(NSUInteger)value	{
	[self stopTimer];
	_bpm = value;
	if(self.on){
		[self startTimer];
	}
}
- (NSUInteger)bpm	{
	return _bpm;
}
- (void) setOn:(bool)on	{
	if (on) [self startTimer];
	else [self stopTimer];
	_on = on;
}
- (bool) on	{
	return _on;
}
@end
