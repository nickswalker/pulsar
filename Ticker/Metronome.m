//
//  MainViewController.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Metronome.h"
#import "Timer.h"
#import "LED.h"
#import "SoundPlayer.h"
#import "DeltaTracker.h"

@implementation Metronome

Timer* timeKeeper;
SoundPlayer* player;
LED* led;
NSUserDefaults* defaults;
DeltaTracker* bpmTracker;
DeltaTracker* timeSignatureTracker;
NSArray* standardTimeSignatures;
int i;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Setup stored defaults
	defaults = [NSUserDefaults standardUserDefaults];
	
	timeKeeper = [[Timer alloc] initWithDelegate: self];
	led = [[LED alloc] init];
	bpmTracker = [[DeltaTracker alloc] init];
	timeSignatureTracker = [[DeltaTracker alloc] init];
	
	//Match the display to the stepper value
	self.stepper.value = [defaults integerForKey:@"bpm"];
	[self updateBPM:self.stepper];
	[defaults setObject:@[@2] forKey:@"accents"];
	NSLog(@"%@", [defaults objectForKey:@"accents"]);
	
	//Setup player
	player =  [[SoundPlayer alloc] init];
	
	//Setup signature
	NSLog(@"%@", [defaults objectForKey:@"timeSignature"]);
	self.timeSignatureControl.timeSignature= [defaults objectForKey:@"timeSignature"];
	self.timeSignatureControl.topControl.accents = [defaults objectForKey:@"accents"];

	// Start running if the metronome is on
	[self toggleTimer:(UISwitch *)self.timerSwitch];
	standardTimeSignatures = @[
							   @[ @4, @4],
							   @[ @2, @4],
							   @[ @6, @8],
							   @[ @3, @4],
							   @[ @9, @8],
							   @[ @3, @8],
							   @[ @12, @8]
							];
}
#pragma mark - UI
-(IBAction)updateBPM:(UIStepper*)sender	{
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	timeKeeper.bpm = (NSUInteger)sender.value;
	[defaults setInteger:(int)sender.value forKey:@"bpm"];
}
- (IBAction)updateTimeSignature:(TimeSignatureControl*)timeSignatureControl	{
	
	timeKeeper.timeSignature = timeSignatureControl.timeSignature;
	[defaults setObject:timeSignatureControl.timeSignature forKey:@"timeSignature"];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	self.timeSignatureControl.topControl.currentBeat = 0;
	if (toggle.on) {
		[timeKeeper startTimer];
		timeKeeper.on=true;
		[UIApplication sharedApplication].idleTimerDisabled = YES;
	}
	else {
		[timeKeeper stopTimer];
		timeKeeper.on=false;
		[UIApplication sharedApplication].idleTimerDisabled = NO;
	}
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
	self.stepper.value = self.stepper.value - -1*translation.y/10;
	[self updateBPM:self.stepper];
	[recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}
//TODO: Document this and add a short averaging mechanism, an array of past time deltas
- (IBAction)matchBpm:(UIButton *)sender {
	
	double delta = [bpmTracker benchmark];
	if(delta == 0) return;
	else if( (60/delta) <20 ){
		[bpmTracker clear];
		[bpmTracker benchmark];
		return;
	}
	self.stepper.value = 60/(delta) ;
	[self updateBPM:self.stepper];
}
- (IBAction)cycleTimeSignature:(id)sender	{
	double delta = [timeSignatureTracker benchmark];
	if( (delta) > 2 ){
		[timeSignatureTracker clear];
		[timeSignatureTracker benchmark];
		i = 0;
	}
	self.timeSignatureControl.timeSignature= [standardTimeSignatures objectAtIndex:i];
	i++;
}
-(void)beat
{
	if ([self.timeSignatureControl.topControl beatIsAccent: timeKeeper.currentBeat]) {
		[player playTickSound];
	}else {
		[player playTockSound];
	}
	self.timeSignatureControl.topControl.currentBeat = timeKeeper.currentBeat;
	if ([defaults boolForKey:@"screenFlash"]) [self flashScreen];
	if ([defaults boolForKey:@"ledFlash"]) [led toggleTorch];
	if ([defaults boolForKey:@"vibrate"]) [player vibrate];
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
	self.timerSwitch.on = false;
	[self toggleTimer:self.timerSwitch];
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
	[timeKeeper stopTimer];
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
