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

NSTimer* timer;
int signature;
SEL flashSelector;
id target;
int bpm;
NSUserDefaults* defaults;

- (id)initWithDelegate:(id)sentTarget
{
	defaults = [NSUserDefaults standardUserDefaults];
    self = [super init];
	if(self){
		
		self.delegate = sentTarget;
		self.on= false;
	}
    return(self);
}
-(void)stopTimer{
	[timer invalidate];
	self.count = 0;
	double speed = INFINITY;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	[self beat:nil];
	double speed = (double)SECONDS/bpm;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)changeBpm:(int)value	{
	[self stopTimer];
	bpm = value;
	if(self.on){
		[self startTimer];
	}
}
- (void)changeSignature:(int)top and:(int)bottom	{
	
	[self stopTimer];
	signature = top;
	if(self.on){
		[self startTimer];
	}
}
-(void)beat:(NSTimer*)timer{
	[self updateCount];
	[self.delegate beat];
	
}
-(void)updateCount{
	self.count +=1;
	if (self.count > signature ) {
		self.count = 1;
	}

	NSLog(@"%d",self.count);
	
}

@end
