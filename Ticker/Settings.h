//
//  FlipsideViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@protocol SettingsViewControllerDelegate
@required
- (void)settingsViewControllerDidFinish:(Settings *)controller;
@end

@interface Settings : UITableViewController

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property IBOutlet UISwitch* vibrationControl;
@property IBOutlet UISwitch* flashControl;
- (IBAction)done:(id)sender;
-(IBAction)toggleFlashing:(UISwitch*)flashingSwitch;
-(IBAction)toggleVibration:(UISwitch*)vibrationSwitch;
@end
