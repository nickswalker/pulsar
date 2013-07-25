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
	self.flashControl.on = [defaults boolForKey:@"flashing"];
	self.vibrationControl.on = [defaults boolForKey:@"vibration"];
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
- (IBAction)toggleFlashing:(UISwitch *)flashingSwitch
{
	 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:flashingSwitch.isOn forKey:@"flashing"];
}
- (IBAction)toggleVibration:(UISwitch *)vibrationSwitch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:vibrationSwitch.isOn forKey:@"vibration"];
}
@end
