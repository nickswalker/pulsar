//
//  TimeSignatureControl.m
//  Ticker
//
//  Created by Nick Walker on 7/28/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "TimeSignatureControl.h"

@implementation TimeSignatureControl
@synthesize timeSignature = _timeSignature;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//    }
//    return self;
//}
-(void)awakeFromNib	{
	NSArray *bottomNumbers = @[@"2", @"4", @"8", @"16"];
	self.bottomControl = [[UISegmentedControl alloc] initWithItems:bottomNumbers];
	self.bottomControl.frame = CGRectMake(0, 33, 175, 29);
	[self.bottomControl addTarget:self action: @selector(updateTimeSignature:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:self.bottomControl];
	
	self.topControl = [[BeatsControl alloc] init];
	self.topControl.backgroundColor = [UIColor clearColor];
	self.topControl.radius = 5;
	self.topControl.frame = CGRectMake(3, 0, 168, 20);
	
	[self.topControl addTarget:self action:@selector(addBeat:) forControlEvents:UIControlEventTouchUpInside];
	[self.topControl addTarget:self action:@selector(updateTimeSignature:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:self.topControl];

}
- (void) updateTimeSignature:(id)sender	{
	self.timeSignature = @[[NSNumber numberWithInt:self.topControl.numberOfBeats], [self.bottomControl titleForSegmentAtIndex:self.bottomControl.selectedSegmentIndex]];
}
- (void)addBeat:(id)sender{
	if (self.topControl.numberOfBeats ==12) self.topControl.numberOfBeats = 1;
	self.topControl.numberOfBeats++;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Getters and Setters

- (void) setTimeSignature:(NSArray *)timeSignature	{
	NSUInteger top = [timeSignature[0] intValue];
	NSUInteger bottom = [timeSignature[1] intValue];
	int index = 0;
	switch (bottom) {
		case 2: index = 0; break;
		case 4: index = 1; break;
		case 8: index = 2; break;
		case 16: index = 3; break;
	}
	
	self.bottomControl.selectedSegmentIndex = index;
	self.topControl.numberOfBeats = top;
	_timeSignature = timeSignature;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
-(NSArray*) timeSignature	{
	return _timeSignature;
}

@end
