//
//  Timer.m
//  Ticker
//
//  Created by Nick Walker on 7/19/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Timer.h"
#define SECONDS 60
#import "DeltaTracker.h"
@implementation Timer

@synthesize bpm = _bpm,
	on = _on,
	timeSignature = _timeSignature;

NSTimer* timer;
id target;
-(Timer*)init{
	self = [super init];
    if (self) {
        self.tracker= [[DeltaTracker alloc] init];
    }
    return self;
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	self.beatPartCount = 1;
	//Fire the first beat as soon as the action is registered so as to allow instant metronome start
	[self beat:nil];
	double gap = (((double)SECONDS)/self.bpm )/24;

	[NSTimer scheduledTimerWithTimeInterval:gap target:self selector:@selector(beat:) userInfo:nil repeats:NO];
	
}
-(void)updateTimer	{
	double gap = (((double)SECONDS)/self.bpm )/24;
	[NSTimer scheduledTimerWithTimeInterval:gap target:self selector:@selector(beat:) userInfo:nil repeats:NO];
}

-(void)beat:(NSTimer*)timer{

	if(self.beatPartCount==25) self.beatPartCount=1;
	
//	float error = [self.tracker benchmark]-((60/(float)self.bpm)/24);
//	NSLog(@"Error: %fms", error*1000 );
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"beat" object:[NSNumber numberWithInt:self.beatPartCount]];
	self.beatPartCount++;
	if(self.on)[self updateTimer];
}

#pragma mark - Getters and Setters

-(void)setBpm:(NSUInteger)value	{
	_bpm = value;

}
- (NSUInteger)bpm	{
	return _bpm;
}
- (void) setOn:(bool)on	{
	if (on) {
		[self startTimer];
	}
	_on = on;
}
- (bool) on	{
	return _on;
}
- (void) setTimeSignature:(NSArray *)timeSignature
{
	_timeSignature = timeSignature;
	int topValue = [timeSignature[0] intValue];
	int bottomValue = [timeSignature[1] intValue];
	switch (bottomValue) {
		case 2:
			self.beatDenomination = half;
			break;
		case 4:
			self.beatDenomination = quarter;
			break;
		case 8:
			self.beatDenomination = eigth;
			break;
		case 16:
			self.beatDenomination = sixteenth;
			break;
		default:
			break;
	}
	if ( topValue > 3 && topValue % 3 == 0 ){
			if ( bottomValue == 8 ) {
				self.beatDenomination = dottedQuarter;
			}
			else if ( bottomValue == 16 ){
				self.beatDenomination = dottedEigth;
			}
	}
}
- (NSArray*) timeSignature	{
	return _timeSignature;
}
@end
