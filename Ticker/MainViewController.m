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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	player = [[SoundPlayer alloc] init];
	[self changeBPM:self.stepper];
	[self startTimer];
	self.whiteScreen = [[UIView alloc] initWithFrame:self.view.frame];
    self.whiteScreen.layer.opacity = 0.0f;
    self.whiteScreen.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self.view addSubview:self.whiteScreen];

}
-(void)stopTimer{
	[timer invalidate];
	double speed = INFINITY;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
	self.isRunning = false;
}
-(void)startTimer{
	[timer invalidate];
	timer = nil;
	double speed = SECONDS/self.stepper.value;
	timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(beat:) userInfo:nil repeats:YES];
	self.isRunning = true;
}
-(IBAction)changeBPM:(UIStepper*)sender	{
	[self stopTimer];
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	[self startTimer];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	if (toggle.on) [self startTimer];
	else [self stopTimer];
	
}
-(void)beat:(NSTimer*)timer{
	//[self updateCount];
	NSLog(@"Beat.");
	[self flashScreen];
}
-(void)updateCount{
	count += 1;
	//if 4/4 timing is selected then the count wont go past 4
	if (self.signature.selectedSegmentIndex == 2) {
		if (count >= 5) {
			count = 1;
		}
	}
	
	//if 3/4 timing is selected then the count wont go past 3
	if (self.signature.selectedSegmentIndex == 1) {
		if (count >= 4) {
			count = 1;
		}
	}
	
	//if 2/4 timing is selected then the count wont go past 2
	if (self.signature.selectedSegmentIndex == 0) {
		if (count >= 3) {
			count = 1;
		}
	}
	//In each timing case it plays the sound on one and depending
	//on the limitiations on the cont value the amount of each tick
	if (count == 1) {
		[player playTockSound];
	}else {
		[player playTickSound];
	}
	//numberLabel.text = [NSString stringWithFormat:@"%i",count];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
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
