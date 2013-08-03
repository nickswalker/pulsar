//
//  MainViewController.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Metronome.h"
#import "MetronomeControl.h"
#import "LED.h"
#import "SoundPlayer.h"
#import "DeltaTracker.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@implementation Metronome


SoundPlayer* player;
LED* led;
NSUserDefaults* defaults;
DeltaTracker* bpmTracker;
DeltaTracker* timeSignatureTracker;
NSArray* standardSettings;
int i;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Setup stored defaults
	defaults = [NSUserDefaults standardUserDefaults];
	[self setSettingsFromDefaults:self.controls];
	led = [[LED alloc] init];
	bpmTracker = [[DeltaTracker alloc] init];
	timeSignatureTracker = [[DeltaTracker alloc] init];
	
	//Setup player
	player =  [[SoundPlayer alloc] init];
	
	//Setup Multipeer
	self.peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
	self.session = [[MCSession alloc] initWithPeer:self.peerID];

	self.controls.delegate = self;
	standardSettings = @[
							   @[ @[ @4, @4], @[@1] ],
							   @[ @[ @2, @4], @[@1] ],
							   @[ @[ @6, @8], @[@1, @4] ],
							   @[ @[ @3, @4], @[@1] ],
							   @[ @[ @9, @8], @[@1, @4, @7] ],
							   @[ @[ @3, @8], @[@1] ],
							   @[ @[ @12, @8], @[@1, @4, @7, @10] ],
							];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncSettingsChangesToDefaults)
												 name:@"syncDefaults"
											   object:nil];
	}

#pragma mark - Model

- (void) syncSettingsChangesToDefaults
{
	NSLog(@"settings sync");
	NSArray* timeSignature = @[ [NSNumber numberWithInt:self.controls.timeSignatureControl.topControl.numberOfBeats], [self.controls.timeSignatureControl.bottomControl titleForSegmentAtIndex:self.controls.timeSignatureControl.bottomControl.selectedSegmentIndex]];
	[defaults setObject: timeSignature forKey:@"timeSignature"];
	[defaults setInteger:(int)self.controls.bpmControl.stepper.value forKey:@"bpm"];
	[defaults synchronize];
}
- (void) setSettingsFromDefaults:(MetronomeControl*)target
{
	target.bpmControl.stepper.value = [defaults integerForKey:@"bpm"];
	[target.bpmControl.stepper sendActionsForControlEvents:UIControlEventValueChanged];
	target.timeSignatureControl.timeSignature= [defaults objectForKey:@"timeSignature"];
	target.timeSignatureControl.topControl.accents = [defaults objectForKey:@"accents"];
	
}

#pragma mark - UI

- (IBAction)matchBpm:(UIButton *)sender
{
	
	self.controls.timeKeeper.on= false;
	double delta = [bpmTracker benchmark];
	if(delta == 0) return;
	else if( (60/delta) <20 ){
		return;
	}
	self.controls.bpmControl.stepper.value= 60/(delta);
	[self.controls.bpmControl.stepper sendActionsForControlEvents:UIControlEventValueChanged];
}
- (IBAction)cycleTimeSignature:(id)sender	{
	double delta = [timeSignatureTracker benchmark];
	if( (delta) > 2 ){
		i = 0;
	}
	if (i>6) {
		i=0;
	}
	self.controls.timeSignatureControl.timeSignature= standardSettings[i][0];
	self.controls.timeSignatureControl.topControl.accents = standardSettings[i][1];
	self.controls.timeSignatureControl.topControl.currentBeat = nil;
	self.controls.timeKeeper.on= true;
	
	i++;
}
-(void)beat:(BeatControl*)beat denomination:(BeatDenomination)denomination part:(NSUInteger)part
{
	if (denomination == dottedQuarter || denomination == dottedEigth) {
		
			if ( part == 1 ) {
				if (beat.accent) [player playAccent];
				else [player playNormal];
			}
			else if ( (part == 9 || part == 17) && [defaults boolForKey:@"division"]) [player playDivision];
			else if ( (part == 5 || part == 13 || part == 21) && [defaults boolForKey:@"subdivision"]) [player playSubdivision];
	}
	else{
		if ( part == 1 ) {
			if (beat.accent) {
				[player playAccent];
				if ([defaults boolForKey:@"screenFlash"]) [self flashScreen];
				if ([defaults boolForKey:@"ledFlash"]) [led toggleTorch];
				if ([defaults boolForKey:@"vibrate"]) [player vibrate];
			}
			else [player playNormal];
		}
		else if ( (part == 13) && [defaults boolForKey:@"division"]){
			[player playDivision];
		}
		else if ( (part == 7 || part == 19) && [defaults boolForKey:@"subdivision"]){
			[player playSubdivision];
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
	self.controls.runningSwitch.on = false;
	[self.controls toggleRunning:self.controls.runningSwitch];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.settingsPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.settingsPopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[self.controls.timeKeeper stopTimer];
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.settingsPopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.settingsPopoverController) {
        [self.settingsPopoverController dismissPopoverAnimated:YES];
        self.settingsPopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
