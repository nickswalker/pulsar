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
	timeSignature = _timeSignature;

NSTimer* timer;
id target;


- (id)initWithDelegate:(id)sentTarget
{
    self = [super init];
	if(self){
		
		self.delegate = sentTarget;
		self.on= false;
	}
    return(self);
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	[self beat:nil];
	double speed = ((double)SECONDS)/self.bpm;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)stopTimer{
	[timer invalidate];
	self.currentBeat = 0;
	double speed = INFINITY;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)beat:(NSTimer*)timer{
	[self updateCount];
	[self.delegate beat];
	
}
-(void)updateCount{
	self.currentBeat +=1;
	if (self.currentBeat > [[self.timeSignature valueForKey:@"top" ] intValue]) self.currentBeat= 1;
	NSLog(@"%u",self.currentBeat);
	
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
- (void)setTimeSignature:(NSDictionary*)timeSignature	{
	
	[self stopTimer];
	_timeSignature = @{ @"top": [timeSignature objectForKey:@"top"], @"bottom": [timeSignature objectForKey:@"bottom"]};
	if(self.on){
		[self startTimer];
	}
}
-(NSDictionary*)timeSignature	{
	return _timeSignature;
}
@end
