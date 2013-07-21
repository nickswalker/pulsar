//
//  Timer.m
//  Ticker
//
//  Created by Nick Walker on 7/19/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Timer.h"

@implementation Timer

-(void)stopTimer{
	[timer invalidate];
	double speed = INFINITY;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
	self.isRunning = false;
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	double speed = SECONDS/self.stepper.value;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
	self.isRunning = true;
}
-(IBAction)changeBPM:(UIStepper*)sender	{
	[self stopTimer];
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	[self startTimer];
}
@end
