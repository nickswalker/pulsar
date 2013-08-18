//
//  FlipsideViewController.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Settings.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
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
	
	self.divisionControl.on = [defaults boolForKey:@"division"];
	self.subdivisionControl.on = [defaults boolForKey:@"subdivision"];
	self.screenFlashControl.on = [defaults boolForKey:@"screenFlash"];
	self.vibrateControl.on = [defaults boolForKey:@"vibrate"];
	self.ledFlashControl.on = [defaults boolForKey:@"ledFlash"];
	
	
	self.masterControl.on = [defaults boolForKey:@"master"];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
	[defaults synchronize];
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
- (IBAction)toggleDivision:(UISwitch *)divisionSwitch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:divisionSwitch.on forKey:@"division"];
}
- (IBAction)toggleSubdivision:(UISwitch *)subdivisionSwitch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:subdivisionSwitch.on forKey:@"subdivision"];
}
- (IBAction)toggleMaster:(UISwitch *)masterSwitch
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:masterSwitch.on forKey:@"master"];
	if (masterSwitch.on) {
		self.view.tintColor = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f];
	}
	else{
		self.view.tintColor = [UIColor colorWithRed:13/255.0f green:204/255.0f blue:0/255.0f alpha:1.0f];
	}
}
#pragma mark - Tableview methods
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if ( section == 2) return [NSString stringWithFormat:@"%@ Version %@ \n Nick Walker", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ];
	return nil;
}
@end
