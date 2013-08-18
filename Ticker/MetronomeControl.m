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
	self.timeKeeper.timeSignature = self.timeSignatureControl.timeSignature;
	self.bpmControl.timeKeeper = self.timeKeeper;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(beat)
												 name:@"beat"
											   object:nil];
}
-(IBAction)controlValueChanged:(id)sender	{
	self.timeKeeper.timeSignature = self.timeSignatureControl.timeSignature;
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
	//NSLog(@"%lu", (unsigned long)self.timeKeeper.beatPartCount);
	if (self.timeKeeper.beatDenomination == dottedEigth || self.timeKeeper.beatDenomination == dottedQuarter) {
		if(self.timeKeeper.beatPartCount == 8 || self.timeKeeper.beatPartCount == 16) [self.timeSignatureControl.topControl advanceBeat];
	}
	if (self.timeKeeper.beatPartCount == 1) {
		[self.timeSignatureControl.topControl advanceBeat];
	}
	[self.delegate beat:self.timeSignatureControl.topControl.currentBeat denomination:self.timeKeeper.beatDenomination part:self.timeKeeper.beatPartCount];
	
}
@end
