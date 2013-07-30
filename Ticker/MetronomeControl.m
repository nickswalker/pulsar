//
//  MetronomeControl.m
//  Ticker
//
//  Created by Nick Walker on 7/29/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "MetronomeControl.h"
#import "bpmControl.h"
#import "TimeSignatureControl.h"

@implementation MetronomeControl

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//    }
//    return self;
//}
- (void) awakeFromNib
{
	self.timeKeeper = [[Timer alloc] init];
	self.bpmControl.timeKeeper = self.timeKeeper;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(beat)
												 name:@"beat"
											   object:nil];
}
-(IBAction)controlValueChanged:(id)sender	{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"syncDefaults" object:self];
}
-(IBAction)toggleRunning:(UISwitch*)toggle
{
	self.timeSignatureControl.topControl.currentBeat = nil;
	if (toggle.on) {
		self.timeKeeper.on= true;
		[UIApplication sharedApplication].idleTimerDisabled = YES;
	}
	else {
		self.timeKeeper.on= false;
		[UIApplication sharedApplication].idleTimerDisabled = NO;
	}
}

- (void)beat
{
	[self.timeSignatureControl.topControl advanceBeat];
	[self.delegate beat:self.timeSignatureControl.topControl.currentBeat];
	
}
@end
