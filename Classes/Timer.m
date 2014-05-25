#import "Timer.h"
#define SECONDS 60
#import "DeltaTracker.h"
@implementation Timer

DeltaTracker* tracker;
BeatDenomination beatDenomination;
NSUInteger beatPartCount;
NSUInteger currentBeat;
bool accent;
double error;
NSTimer* timer;
id target;

@synthesize bpm = _bpm,
	on = _on,
	timeSignature = _timeSignature;

-(Timer*)init{
	self = [super init];
    if (self) {
        tracker= [[DeltaTracker alloc] init];
    }
    return self;
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	
	currentBeat = 1;
	beatPartCount = 1;
	//This needs to change actually because the first beat might be an accent. We need to send the actual first beat along for the ride
	//Fire the first beat as soon as the action is registered so as to allow instant metronome start
	[self beat:nil];
	double gap = (((double)SECONDS)/self.bpm )/24;
//  NSLog(@"%lu", (unsigned long)self.bpm);
	timer = [NSTimer scheduledTimerWithTimeInterval:gap target:self selector:@selector(beat:) userInfo:nil repeats:YES];
	
}
- (void)stopTimer{
	[timer invalidate];
	timer = nil;
}
-(void)updateTimer	{
	[timer invalidate];
	timer = nil;
	double gap = (((double)SECONDS)/self.bpm )/24;
	
	timer= [NSTimer scheduledTimerWithTimeInterval:gap target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}

-(void)beat:(NSTimer*)timer{
	accent = false;
	if(beatPartCount>24) {
		
		beatPartCount=1;
		if( currentBeat>[self.timeSignature[0] intValue] ) currentBeat = 1;
		NSLog(@"%d", currentBeat);
		accent = [self beatIsAccent:currentBeat];
		NSLog(@"%d", accent);
	}
	
//	error = [tracker benchmark]-((60/(double)self.bpm)/24);
//	NSLog(@"Error: %fms", error*1000 );
	NSNumber *denomination = [NSNumber numberWithUnsignedInteger: beatDenomination];
	NSNumber* part = [NSNumber numberWithUnsignedInteger:beatPartCount];
	NSNumber* number = [NSNumber numberWithUnsignedInteger:currentBeat];
	NSNumber* isAccent = [NSNumber numberWithBool:accent];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"beat" object:self userInfo:@{@"beatPartCount": part, @"beatDenomination": denomination, @"beatNumber": number, @"accent": isAccent}];
	if(beatPartCount == 1) currentBeat++;
	beatPartCount++;
	
	
//if(self.on)[self updateTimer];
}

- (bool)beatIsAccent:(NSUInteger)beat{
	NSNumber* testBeat = [NSNumber numberWithInt:beat];
	for (NSNumber* accentedBeat in self.accents) {
		if ( [accentedBeat isEqualToNumber:testBeat] ) {
			return true;
		}
	}
	return false;
	
}

#pragma mark - Getters and Setters

-(void)setBpm:(NSUInteger)value	{
	_bpm = value;
	if (self.on) {
		[self updateTimer];
	}

}
- (NSUInteger)bpm	{
	return _bpm;
}
- (void) setOn:(bool)on	{
	if (on) {
		[self startTimer];
	}
	else [self stopTimer];
	_on = on;
}
- (bool) on	{
	return _on;
}
- (void) setTimeSignature:(NSArray *)timeSignature
{
	_timeSignature = timeSignature;
	int numerator = [timeSignature[0] intValue];
	int denominator = [timeSignature[1] intValue];
	beatDenomination = denominator;
	if ( numerator > 3 && numerator % 3 == 0 ){
		if ( denominator == 8 ) {
			beatDenomination = dottedQuarter;
		}
		else if ( denominator == 16 ){
			beatDenomination = dottedEigth;
		}
	}
	[self stopTimer];
	if (self.on) [self startTimer];
}
- (NSArray*) timeSignature	{
	return _timeSignature;
}
@end
