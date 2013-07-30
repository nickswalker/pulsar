//
//  SignatureDisplay.m
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "BeatsControl.h"
#import "BeatControl.h"

@implementation BeatsControl
@synthesize numberOfBeats = _numberOfBeats,
currentBeat = _currentBeat,
accents = _accents;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.tapRecognizer = [[UITapGestureRecognizer alloc] init];
		[self.tapRecognizer addTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:self.tapRecognizer];
    }
    return self;
}
- (void)handleTap:(UITapGestureRecognizer*)recognizer{
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
- (void)updateAccent:(BeatControl*)beat	{
	NSMutableArray* tempArray;
	if([self beatIsAccent:beat.number]){
		tempArray = [self.accents mutableCopy] ;
		[tempArray removeObject:[NSNumber numberWithInt:beat.number]];
	}
	else{
		tempArray = [self.accents mutableCopy] ;
		[tempArray addObject:[NSNumber numberWithInt:beat.number]];
	}
	self.accents = tempArray;
}
- (void) advanceBeat	{
	int currentBeatNumber = (int)self.currentBeat.number;
	int newCurrentBeatNumber = currentBeatNumber+1;
	if(currentBeatNumber == (int)self.numberOfBeats) newCurrentBeatNumber = 1;
	
	NSLog(@"Current beat:%d Next beat: %d", currentBeatNumber, newCurrentBeatNumber);
	for (BeatControl* beat in [self subviews]) {
		int beatNumber = (int)beat.number;
		if(beatNumber == currentBeatNumber) beat.current = false;
		if(beatNumber == newCurrentBeatNumber) beat.current = true, self.currentBeat = beat;
	}

}
- (void)drawRect:(CGRect)rect
{
	[self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	[self clearsContextBeforeDrawing];
	int xwidth = rect.size.width/self.numberOfBeats;
	for (int i = 0; i < self.numberOfBeats; i++) {
		CGRect tempRect = CGRectMake((i*xwidth), 0, xwidth, rect.size.height);
		BeatControl* tempBeatControl = [[BeatControl alloc] init];
		tempBeatControl.frame = tempRect;
		tempBeatControl.backgroundColor = [UIColor clearColor];
		tempBeatControl.number = i+1;
		if([self beatIsAccent:i+1]) tempBeatControl.accent = true;
		else tempBeatControl.accent = false;
		if (i+1 == self.currentBeat.number) tempBeatControl.current = true;
		else tempBeatControl.current = false;
		[tempBeatControl addTarget:self action:@selector(updateAccent:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:tempBeatControl];
	}
}
- (bool)beatIsAccent:(NSUInteger)beat{
	NSNumber* testBeat = [NSNumber numberWithInt:beat];
	for (NSNumber* beatInCycle in self.accents) {
		if ( [beatInCycle isEqualToNumber:testBeat] ) {
			return true;
		}
	}
			 return false;
	
}

#pragma mark - Getters and Setters

- (NSUInteger)numberOfBeats	{
	return _numberOfBeats;
}

- (void)setNumberOfBeats:(NSUInteger)numberOfBeats	{
	_numberOfBeats = numberOfBeats;
	[self setNeedsDisplay];
}
- (BeatControl*)currentBeat	{
	return _currentBeat;
}

- (void)setCurrentBeat:(BeatControl*)currentBeat	{
	_currentBeat = currentBeat;
	[self setNeedsDisplay];
}
- (NSArray*)accents	{
	return _accents;
}

- (void)setAccents:(NSArray*)accents	{
	_accents = accents;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"syncDefaults" object:self];
}
@end
