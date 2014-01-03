#import "Timer.h"
#define SECONDS 60
#import "DeltaTracker.h"
@implementation Timer

DeltaTracker* tracker;
BeatDenomination beatDenomination;
NSUInteger beatPartCount;

@synthesize bpm = _bpm,
	on = _on,
	timeSignature = _timeSignature;
double error;
NSTimer* timer;
id target;
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
	
	beatPartCount = 1;
	//This needs to change actually because the first beat might be an accent. We need to send the actual first beat along for the ride
	//Fire the first beat as soon as the action is registered so as to allow instant metronome start
	[self beat:nil];
	double gap = (((double)SECONDS)/self.bpm )/24;
	NSLog(@"%f", gap);
	NSLog(@"%lu", (unsigned long)self.bpm);
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

	if(beatPartCount==25) beatPartCount=1;
	
//	error = [tracker benchmark]-((60/(double)self.bpm)/24);
//	NSLog(@"Error: %fms", error*1000 );
	NSNumber *denomination = [NSNumber numberWithUnsignedInteger: beatDenomination];
	NSNumber* part = [NSNumber numberWithUnsignedInteger:beatPartCount];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"beat" object:self userInfo:@{@"beatPartCount": part, @"beatDenomination": denomination}];
	beatPartCount++;
//if(self.on)[self updateTimer];
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
