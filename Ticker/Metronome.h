//
//  MainViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Settings.h"
#import "Timer.h"
#import "MetronomeControl.h"
#import "BeatControl.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Metronome : UIViewController <SettingsViewControllerDelegate, MetronomeControlDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (nonatomic, strong)IBOutlet UIButton *backgroundButton;
@property IBOutlet MetronomeControl* controls;


- (IBAction)matchBpm:(UIButton *)sender;
- (IBAction)cycleTimeSignature:(id)sender;
- (void)flashScreen;
- (void)beat:(BeatsControl*)beat;
- (void)setSettingsFromDefaults:(MetronomeControl*)target;
- (void)settingsViewControllerDidFinish:(Settings *)controller;
- (void)syncSettingsChangesToDefaults;

@end
