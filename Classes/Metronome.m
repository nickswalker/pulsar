#import "Metronome.h"
#import "MetronomeControl.h"
#import "LED.h"
#import "SoundPlayer.h"
#import "DeltaTracker.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation Metronome

LED* led;

DeltaTracker* bpmTracker;
DeltaTracker* timeSignatureTracker;
NSArray* standardSettings;
NSUserDefaults* defaults;
int i;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.screenName = @"Metronome";
	
	self.timeTracker= [[DeltaTracker alloc] init];

	led = [[LED alloc] init];
	bpmTracker = [[DeltaTracker alloc] init];
	timeSignatureTracker = [[DeltaTracker alloc] init];
	
	//Setup player
	[SoundPlayer loadSounds];
	
	//Setup Multipeer
	self.peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
	self.session = [[MCSession alloc] initWithPeer:self.peerID];

	standardSettings = @[
							   @[ @[ @4, @4], @[@1] ],
							   @[ @[ @2, @4], @[@1] ],
							   @[ @[ @6, @8], @[@1] ],
							   @[ @[ @3, @4], @[@1] ],
							   @[ @[ @9, @8], @[@1] ],
							   @[ @[ @3, @8], @[@1] ],
							   @[ @[ @12, @8], @[@1] ],
							];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(beat:)
												 name:@"beat"
											   object:nil];
	defaults = [NSUserDefaults standardUserDefaults];
	}

#pragma mark - Model


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - UI

- (IBAction)matchBpm:(id)sender
{
	
	double delta = [bpmTracker benchmark];
	
	if(delta == 0) return;
	else if( (60/delta) <20 ){
		return;
	}
	self.controls.bpm = 60/(delta);
}

- (IBAction)cycleTimeSignature:(id)sender	{
	double delta = [timeSignatureTracker benchmark];
	if( (delta) > 2 ){
		i = 0;
	}
	if (i>6) {
		i=0;
	}
	self.controls.timeSignature= standardSettings[i][0];
	self.controls.accents = standardSettings[i][1];
	
	i++;
}
- (void)beat:(NSNotification*)notification
{
	BeatDenomination denomination = [[[notification userInfo] objectForKey:@"beatDenomination"] intValue];
	NSUInteger part = [[[notification userInfo] objectForKey:@"beatPartCount"] intValue];
	bool accent = [[[notification userInfo] objectForKey:@"accent"] boolValue];
	if (denomination == dottedQuarter || denomination == dottedEigth) {
		
			if ( part == 1 ) {
//				double error = [self.tracker benchmark]*1000;
//				NSLog(@"Overall Error: %fms", error );
				if (accent) {
					[SoundPlayer playAccent];
					[self flashScreen];
					if ([defaults boolForKey:@"ledFlash"]) [LED toggleTorch];
					if ([defaults boolForKey:@"vibrate"]) [SoundPlayer vibrate];
				}
				else {
					[SoundPlayer playBeat];
					if ([defaults boolForKey:@"screenFlash"]) [self flashScreen];
				}
			}
			else if ( (part == 9 || part == 17) && [defaults boolForKey:@"division"]) [SoundPlayer playDivision];
			else if ( (part == 5 || part == 13 || part == 21) && [defaults boolForKey:@"subdivision"]) [SoundPlayer playSubdivision];
	}
	else{
		if ( part == 1 ) {
//			double error = [self.tracker benchmark]*1000;
//			NSLog(@"Overall Error: %fms", error );
			if (accent) {
				[SoundPlayer playAccent];
				[self flashScreen];
				if ([defaults boolForKey:@"ledFlash"]) [LED toggleTorch];
				if ([defaults boolForKey:@"vibrate"]) [SoundPlayer vibrate];
			}
			else{
				[SoundPlayer playBeat];
				if ([defaults boolForKey:@"screenFlash"]) [self flashScreen];
			}
		}
		else if ( (part == 13) && [defaults boolForKey:@"division"]){
			[SoundPlayer playDivision];
		}
		else if ( (part == 7 || part == 19) && [defaults boolForKey:@"subdivision"]){
			[SoundPlayer playSubdivision];
		}
	}

	
//	if ( [defaults boolForKey:@"triplet"] && (part == 8 ) || (part == 16) ){
//		[player playTriplet];
//	}
}
-(void)flashScreen {
	self.backgroundButton.layer.opacity = .02;
	self.backgroundButton.backgroundColor = [UIColor whiteColor];
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    NSArray *animationValues = @[ @0.8f, @0.0f ];
    NSArray *animationTimes = @[ @0.3f, @1.0f ];
    id timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    NSArray *animationTimingFunctions = @[ timingFunction, timingFunction ];
    [opacityAnimation setValues:animationValues];
    [opacityAnimation setKeyTimes:animationTimes];
    [opacityAnimation setTimingFunctions:animationTimingFunctions];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.duration = 0.15;
	
    [self.backgroundButton.layer addAnimation:opacityAnimation forKey:@"animation"];
}


#pragma mark - settings View Controller

- (void)settingsViewControllerDidFinish:(Settings *)controller
{

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.settingsPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	self.controls.running = false;
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
