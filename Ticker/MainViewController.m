//
//  MainViewController.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "MainViewController.h"
#import "SoundPlayer.h"
#define SECONDS 60
//@interface MainViewController ()
//@end
@implementation MainViewController

NSTimer* timer;
int count;
SoundPlayer* player;
NSUserDefaults* defaults;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Setup stored defaults
	defaults = [NSUserDefaults standardUserDefaults];
	
	//Setup audio
	player = [[SoundPlayer alloc] init];
	
	//Match the display to the stepper value
	[self changeBPM:self.stepper];
	
	//Setup flashing view
	self.whiteScreen = [[UIView alloc] initWithFrame:self.view.frame];
    self.whiteScreen.layer.opacity = 0.0f;
    self.whiteScreen.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self.view addSubview:self.whiteScreen];
	
	count= 1;
	// Start running if the metronome is on
	if (self.timerSwitch.on) [self startTimer];
}
-(void)stopTimer{
	[timer invalidate];
	count = 1;
	double speed = INFINITY;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	double speed = SECONDS/self.stepper.value;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
}
-(IBAction)changeBPM:(UIStepper*)sender	{
	if(self.timerSwitch.on){
		[self stopTimer];
		self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
		[self startTimer];
	}
	else self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	if (toggle.on) [self startTimer];
	else [self stopTimer];
	
}
- (IBAction)changeSignature:(UISegmentedControl *)signature	{
	[self stopTimer];
	count = 1;
	[self startTimer];
}
-(void)beat:(NSTimer*)timer{
	[self updateCount];
	if ([defaults boolForKey:@"flashing"]) {
		[self flashScreen];
	};
	
}
-(void)updateCount{
	
	//if 4/4 timing is selected then the count wont go past 4
	if (self.signature.selectedSegmentIndex+1 < count) {
			count = 1;
	}

	if (count == 1) {
		[player playTickSound];
	}else {
		[player playTockSound];
	}
	NSLog(@"%d", count);
	count += 1;
}
-(void)flashScreen {
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
    opacityAnimation.duration = 0.4;
	
    [self.whiteScreen.layer addAnimation:opacityAnimation forKey:@"animation"];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
	self.stepper.value = self.stepper.value - -1*translation.y/10;
	[self changeBPM:self.stepper];
	[recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	NSLog(@"Recieved through protocol");
	if (self.timerSwitch.isOn) [self startTimer];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[self stopTimer];
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
