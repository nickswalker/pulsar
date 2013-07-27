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
#import "deltaTracker.h"
#import <CoreBluetooth/CoreBluetooth.h>
//@interface MainViewController ()
//@end
@implementation Metronome

Timer* timeKeeper;
SoundPlayer* player;
LED* led;
NSUserDefaults* defaults;
double startTime;
double endTime;
NSDictionary* standardTimeSignatures;
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Setup stored defaults
	defaults = [NSUserDefaults standardUserDefaults];
	
	timeKeeper = [[Timer alloc] initWithDelegate: self];
	led = [[LED alloc] init];
	
	//Match the display to the stepper value
	self.stepper.value = [defaults integerForKey:@"bpm"];
	[self updateBPM:self.stepper];
	self.signatureBottom.selectedSegmentIndex = [defaults integerForKey:@"timeSignatureBottom"] ;

	//Setup player
	player =  [[SoundPlayer alloc] init];
	
	//Setup top signature
	self.signatureTop.numberOfDots = [defaults integerForKey:@"timeSignatureTop"];
	self.signatureTop.currentDot = 1;

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
//TODO: Document this and add a short averaging mechanism, an array of past time deltas
- (IBAction)matchBpm:(UIButton *)sender {
	deltaTracker* tracker = [[deltaTracker alloc] init];
	double delta = [tracker benchmark];
	if(!delta) return;
	else if( (60/delta) <20 ){
		[tracker clear];
		[tracker benchmark];
		return;
	}
	self.stepper.value = 60/(delta) ;
	[self updateBPM:self.stepper];
}
#pragma mark - UI
-(IBAction)updateBPM:(UIStepper*)sender	{
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	timeKeeper.bpm = sender.value;
	[defaults setInteger:(int)sender.value forKey:@"bpm"];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	if (toggle.on) [timeKeeper startTimer], timeKeeper.on=true;
	else [timeKeeper stopTimer], timeKeeper.on=false;
}
- (IBAction)updateTimeSignature:(id)sender	{
	int top = self.signatureTop.numberOfDots;
	int bottom = [[self.signatureBottom titleForSegmentAtIndex:self.signatureBottom.selectedSegmentIndex] intValue];
	timeKeeper.timeSignature = @{ @"top" : [NSNumber numberWithInt:top], @"bottom": [NSNumber numberWithInt:bottom] };
	[defaults setInteger:bottom forKey:@"timeSignatureBottom"];
	[defaults setInteger:top forKey:@"timeSignatureTop"];
}
- (void) changeTimeSignature:(NSDictionary *)timeSignature	{
	timeKeeper.timeSignature = timeSignature;
	[defaults setInteger:(int)[timeSignature objectForKey:@"bottom"] forKey:@"timeSignatureBottom"];
	[defaults setInteger:(int)[timeSignature objectForKey:@"top"] forKey:@"timeSignatureTop"];
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
	self.stepper.value = self.stepper.value - -1*translation.y/10;
	[self updateBPM:self.stepper];
	[recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}
- (IBAction)cycleSignatures:(id)sender	{
	deltaTracker* tracker = [[deltaTracker alloc] init];
	double delta = [tracker benchmark];
	if( (delta) > 2 ){
		[tracker clear];
		[tracker benchmark];
	}

	NSLog(@"Double");
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
	self.backgroundButton.layer.opacity = 0;
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

#pragma mark - BlueTooth

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
