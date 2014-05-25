#import "MeasureControl.h"
#import "BeatControl.h"

@implementation MeasureControl
@synthesize timeSignature = _timeSignature;

BeatsControl* beatsControl;
UISegmentedControl* denominatorControl;


-(id)initWithFrame:(CGRect)frame	{
	self = [super initWithFrame:frame];
    if (self) {
		
		beatsControl = [[BeatsControl alloc] initWithFrame:CGRectMake(2, 0, self.frame.size.width-4, 45)];
		beatsControl.backgroundColor = [UIColor clearColor];
		
		[beatsControl addTarget:self action:@selector(userChangedTimeSignature) forControlEvents:UIControlEventValueChanged];
		[self addSubview:beatsControl];
		
		NSArray *bottomNumbers = @[@"2", @"4", @"8", @"16"];
		denominatorControl = [[UISegmentedControl alloc] initWithItems:bottomNumbers];
		denominatorControl.frame = CGRectMake(0, 45, self.frame.size.width, 29);
		[denominatorControl addTarget:self action: @selector(userChangedTimeSignature) forControlEvents:UIControlEventValueChanged];
		[self addSubview:denominatorControl];
	}
	return self;
}
- (void) userChangedTimeSignature	{
	self.timeSignature = @[[NSNumber numberWithInt:beatsControl.numberOfBeats], [denominatorControl titleForSegmentAtIndex:denominatorControl.selectedSegmentIndex]];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
- (void) userChangedAccents	{
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}


#pragma mark - Getters and Setters

- (void) setTimeSignature:(NSArray *)timeSignature	{
	beatsControl.currentBeat = nil;
	NSUInteger denominator = [timeSignature[1] intValue];
	int index = 0;
	switch (denominator) {
		case 2: index = 0; break;
		case 4: index = 1; break;
		case 8: index = 2; break;
		case 16: index = 3; break;
	}
	
	denominatorControl.selectedSegmentIndex = index;
	_timeSignature = timeSignature;

	beatsControl.numberOfBeats = [timeSignature[0] intValue];
}
- (NSArray*) timeSignature	{
	return _timeSignature;
}

- (NSArray*) accents	{
	return beatsControl.accents;
}
- (void) setAccents:(NSArray *)accents	{
	beatsControl.accents = accents;
}

@end
