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
	NSLog(@"%d",[[defaults objectForKey:@"timeSignatureTop"] intValue]);
	[self changeTimeSignature:@{@"top": [defaults objectForKey:@"timeSignatureTop"], @"bottom": [defaults objectForKey:@"timeSignatureBottom"]}];

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
	timeKeeper.bpm = sender.value;
	[defaults setInteger:(int)sender.value forKey:@"bpm"];
}
- (IBAction)updateTimeSignature:(id)sender	{
	int top = self.signatureTop.numberOfDots;
	int bottom = [[self.signatureBottom titleForSegmentAtIndex:self.signatureBottom.selectedSegmentIndex] intValue];
	NSDictionary* tempDict = @{ @"top" : [NSNumber numberWithInt:top], @"bottom": [NSNumber numberWithInt:bottom] };
	[self changeTimeSignature:tempDict];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	self.signatureTop.currentDot = 0;
	if (toggle.on) [timeKeeper startTimer], timeKeeper.on=true;
	else [timeKeeper stopTimer], timeKeeper.on=false;
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
- (IBAction)cycleSignatures:(id)sender	{
	double delta = [timeSignatureTracker benchmark];
	if( (delta) > 2 ){
		[timeSignatureTracker clear];
		[timeSignatureTracker benchmark];
	}

}
-(void)beat
{
	if (timeKeeper.currentBeat == 1) {
		[player playTickSound];
	}else {
		[player playTockSound];
	}
	self.signatureTop.currentDot = timeKeeper.currentBeat;
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

- (void) changeTimeSignature:(NSDictionary *)timeSignature	{
	int index = 0;
	NSLog(@"%@", timeSignature);
	int top = [[timeSignature objectForKey:@"top"] integerValue];
	int bottom = [[timeSignature objectForKey:@"bottom"] integerValue];
	NSLog(@"%d",top);
	switch (bottom) {
		case 2: index = 0; break;
		case 4: index = 1; break;
		case 8: index = 2; break;
		case 16: index = 3; break;
			
	}
	self.signatureBottom.selectedSegmentIndex = index;
	self.signatureTop.numberOfDots = top;
	self.signatureTop.currentDot = 0;
	timeKeeper.timeSignature = timeSignature;
	[defaults setInteger: bottom forKey:@"timeSignatureBottom"];
	[defaults setInteger: top forKey:@"timeSignatureTop"];
}
#pragma mark - settings View Controller

- (void)settingsViewControllerDidFinish:(Settings *)controller
{
	if (self.timerSwitch.isOn) [timeKeeper startTimer];
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
