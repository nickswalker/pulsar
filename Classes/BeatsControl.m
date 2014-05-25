#import "BeatsControl.h"
#import "BeatControl.h"
#import "Timer.h"

@implementation BeatsControl

@synthesize  numberOfBeats = _numberOfBeats,
currentBeat = _currentBeat,
accents = _accents;

UITapGestureRecognizer* tapRecognizer;
UIButton* backgroundButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		tapRecognizer = [[UITapGestureRecognizer alloc] init];
		[tapRecognizer addTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:tapRecognizer];
    }
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(beat:)
												 name:@"beat"
											   object:nil];
    return self;
}
- (void)handleTap:(UITapGestureRecognizer*)recognizer{
	[self addBeat];
}
- (void)userChangedAccent:(BeatControl*)beat	{
	NSMutableArray* tempArray;
	if([self beatIsAccent:beat.number]){
		tempArray = [self.accents mutableCopy] ;
		NSLog(@"%@",@"is");
		[tempArray removeObject:[NSNumber numberWithInt:beat.number]];
	}
	else{
		tempArray = [self.accents mutableCopy] ;
		[tempArray addObject:[NSNumber numberWithInt:beat.number]];
	}
	self.accents = tempArray;
}
- (void)beat:(NSNotification *)notification
{
	BeatDenomination denomination = [[[notification userInfo] objectForKey:@"beatDenomination"] intValue];
	NSUInteger part = [[[notification userInfo] objectForKey:@"beatPartCount"] intValue];
	//NSLog(@"%lu", (unsigned long)self.timeKeeper.beatPartCount);
	if (part == dottedEigth || denomination == dottedQuarter) {
		if(part == 8 || part == 16) [self advanceBeat];
	}
	if (part == 1) {
		[self advanceBeat];
	}

	
}
- (void) advanceBeat	{
	int currentBeatNumber = (int)self.currentBeat.number;
	int newCurrentBeatNumber = currentBeatNumber+1;
	if(currentBeatNumber == (int)self.numberOfBeats) newCurrentBeatNumber = 1;
	
	//NSLog(@"Current beat:%d Next beat: %d", currentBeatNumber, newCurrentBeatNumber);
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
	for (int i = 1; i <= self.numberOfBeats; i++) {
		CGRect tempRect = CGRectMake(((i-1)*xwidth), 0, xwidth, rect.size.height);
		BeatControl* tempBeatControl = [[BeatControl alloc] init];
		tempBeatControl.frame = tempRect;
		tempBeatControl.backgroundColor = [UIColor clearColor];
		tempBeatControl.number = i;
		if([self beatIsAccent:i]) tempBeatControl.accent = true;
		else tempBeatControl.accent = false;

		if (i == self.currentBeat.number) tempBeatControl.current = true;
		else tempBeatControl.current = false;
		[tempBeatControl addTarget:self action:@selector(userChangedAccent:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:tempBeatControl];
	}
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
- (void)addBeat{
	if (self.numberOfBeats ==12) self.numberOfBeats = 1;
	self.numberOfBeats++;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];

}
- (void) clearDisplay	{
	self.currentBeat = nil;
	[self setNeedsDisplay];
}
#pragma mark - Getters and Setters

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
