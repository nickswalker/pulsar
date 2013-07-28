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
NSDictionary* standardTimeSignatures;

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
	

	//Setup player
	player =  [[SoundPlayer alloc] init];
	
	//Setup signature
	self.timeSignatureControl.timeSignature= @{@"top": [defaults objectForKey:@"timeSignatureTop"], @"bottom": [defaults objectForKey:@"timeSignatureBottom"]};

	// Start running if the metronome is on
	[self toggleTimer:(UISwitch *)self.timerSwitch];
	standardTimeSignatures = @{
											 @1: @{@"top": @4, @"bottom":@4},
											 @2: @{@"top": @2, @"bottom":@4},
											 @3: @{@"top": @6, @"bottom":@8},
											 @4: @{@"top": @3, @"bottom":@4},
											 @5: @{@"top": @9, @"bottom":@8},
											 @5: @{@"top": @3, @"bottom":@8},
											 @6: @{@"top": @12, @"bottom":@8},
											 };
}
#pragma mark - UI
-(IBAction)updateBPM:(UIStepper*)sender	{
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	timeKeeper.bpm = (NSUInteger)sender.value;
	[defaults setInteger:(int)sender.value forKey:@"bpm"];
}
- (IBAction)updateTimeSignature:(TimeSignatureControl*)timeSignatureControl	{
	int top = [[timeSignatureControl.timeSignature objectForKey:@"top"] integerValue];
	int bottom = [[timeSignatureControl.timeSignature objectForKey:@"bottom"] integerValue];
	
	
	timeKeeper.timeSignature = timeSignatureControl.timeSignature;
	[defaults setInteger: bottom forKey:@"timeSignatureBottom"];
	[defaults setInteger: top forKey:@"timeSignatureTop"];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	self.timeSignatureControl.topControl.currentDot = 0;
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
	}
	//Iterate over the common signatures and send them to the control. Pass the new control to the updateTimeSignatureMethod

}
-(void)beat
{
	if (timeKeeper.currentBeat == 1) {
		[player playTickSound];
	}else {
		[player playTockSound];
	}
	self.timeSignatureControl.topControl.currentDot = timeKeeper.currentBeat;
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
