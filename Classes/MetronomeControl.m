#import "MetronomeControl.h"
#import "BPMControl.h"
#import "MeasureControl.h"
#import "Timer.h"

@implementation MetronomeControl

Timer* timeKeeper;
BPMControl* bpmControl;
UISwitch *runningSwitch;
MeasureControl* measureControl;
NSUserDefaults* defaults;

@synthesize running = _running;

- (void) awakeFromNib
{
	
	bpmControl = [[BPMControl alloc] initWithFrame:  CGRectMake(0, 0, self.frame.size.width, 150)];
	[bpmControl addTarget:self action:@selector(bpmControlChanged:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:bpmControl];
	
	measureControl = [[MeasureControl alloc] initWithFrame:  CGRectMake(0, 131, self.frame.size.width, 75)];
	[measureControl addTarget:self action:@selector(measureControlChanged:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:measureControl];

	runningSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -52/2, 230, 0, 0)];
	runningSwitch.onTintColor = [self tintColor];
	[runningSwitch addTarget:self action:@selector(switchControlChanged:) forControlEvents:UIControlEventValueChanged];
	[self addSubview:runningSwitch];
	
	timeKeeper = [[Timer alloc] init];
	timeKeeper.timeSignature = measureControl.timeSignature;

	defaults = [NSUserDefaults standardUserDefaults];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncSettingsChangesToDefaults)
												 name:@"syncDefaults"
											   object:nil];
	[self setSettingsFromDefaults];
}
// This needs to be modified to toggle on tap down.

- (void) syncSettingsChangesToDefaults
{
	NSLog(@"settings sync");
	[defaults setObject: self.timeSignature forKey:@"timeSignature"];
	[defaults setInteger: self.bpm forKey:@"bpm"];
	[defaults setObject: self.accents forKey:@"accents"];
	[defaults synchronize];
}
- (void) setSettingsFromDefaults
{
	self.bpm = [defaults integerForKey:@"bpm"];
	self.timeSignature= [defaults objectForKey:@"timeSignature"];
	self.accents = [defaults objectForKey:@"accents"];
	
}
//Functions called when a ui interaction causes a change. There should be no other entrance to these codepaths.
- (void)measureControlChanged:(MeasureControl*)control	{
	self.timeSignature = control.timeSignature;
}
- (void)switchControlChanged:(UISwitch*)control	{
	self.running = control.on;
}
- (void)bpmControlChanged:(BPMControl*)control	{
	self.bpm = control.bpm;
}

//Facade for all of the nitty gritty below
//Eventually, you should really replace this with KVO
- (NSUInteger) bpm	{
	return bpmControl.bpm;
}
- (void) setBpm:(NSUInteger)bpm{
	bpmControl.bpm = bpm;
	timeKeeper.bpm = bpm;
}
- (NSArray*) timeSignature	{
	return measureControl.timeSignature;
}
- (void) setTimeSignature:(NSArray *)timeSignature	{
	NSLog(@"updating ts");
	measureControl.timeSignature = timeSignature;
	timeKeeper.timeSignature = timeSignature;
}
- (NSArray*) accents	{
	return measureControl.accents;
}
- (void) setAccents:(NSArray *)accents	{
	measureControl.accents = accents;
	timeKeeper.accents = accents;
}
- (BOOL) running{
	return timeKeeper.on;
}
- (void) setRunning:(BOOL)running{
	timeKeeper.on = running;
	runningSwitch.on = running;

	[UIApplication sharedApplication].idleTimerDisabled = running;
}
@end
