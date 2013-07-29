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
	NSLog(@"tap");
	if (self.numberOfBeats ==12) self.numberOfBeats = 1;
	self.numberOfBeats++;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
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
		if (i+1 == self.currentBeat) tempBeatControl.current = true;
		else tempBeatControl.current = false;
		
		[tempBeatControl addTarget:self action:@selector(updateAccent:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:tempBeatControl];
	}
}
- (bool)beatIsAccent:(NSUInteger)beat{
	NSNumber* testBeat = [NSNumber numberWithInt:beat];
	for (NSNumber* beat in self.accents) {
		if ( [beat isEqualToNumber:testBeat] ) {
			return true;
		}
	}
			 return false;
	
}
- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        NSLog(@"Long Press");
    }
}
#pragma mark - Getters and Setters

- (NSUInteger)numberOfBeats	{
	return _numberOfBeats;
}

- (void)setNumberOfBeats:(NSUInteger)numberOfBeats	{
	_numberOfBeats = numberOfBeats;
	[self setNeedsDisplay];
}
- (NSUInteger)currentBeat	{
	return _currentBeat;
}

- (void)setCurrentBeat:(NSUInteger)currentBeat	{
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
}
@end
