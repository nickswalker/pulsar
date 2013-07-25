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
@property IBOutlet UISwitch* vibrateControl;
@property IBOutlet UISwitch* screenFlashControl;
@property IBOutlet UISwitch* ledFlashControl;
@property IBOutlet UISwitch* masterControl;

-(IBAction)done:(id)sender;
-(IBAction)toggleScreenFlash:(UISwitch*)screenFlashSwitch;
-(IBAction)toggleLedFlash:(UISwitch*)ledSwitch;
-(IBAction)toggleVibrate:(UISwitch*)vibrateSwitch;
-(IBAction)toggleMaster:(UISwitch*)masterSwitch;
@end
