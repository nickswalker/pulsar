//
//  FlipsideViewController.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Settings.h"

@implementation Settings
NSUserDefaults *defaults;

- (void)awakeFromNib
{
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Make switches reflect defaults
	defaults = [NSUserDefaults standardUserDefaults];
	self.screenFlashControl.on = [defaults boolForKey:@"screenFlash"] || true;
	self.vibrateControl.on = [defaults boolForKey:@"vibrate"] || false;
	self.ledFlashControl.on = [defaults boolForKey:@"ledFlash"] || false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate settingsViewControllerDidFinish:self];
}
- (IBAction)toggleScreenFlash:(UISwitch *)screenFlashSwitch
{
	 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:screenFlashSwitch.on forKey:@"screenFlash"];
}
- (IBAction)toggleVibrate:(UISwitch *)vibrateSwitch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:vibrateSwitch.on forKey:@"vibrate"];
}
- (IBAction)toggleLedFlash:(UISwitch *)ledSwitch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:ledSwitch.on forKey:@"ledFlash"];
}
@end
