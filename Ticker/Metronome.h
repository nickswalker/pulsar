//
//  MainViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Settings.h"
#import "Timer.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Metronome : UIViewController <SettingsViewControllerDelegate, TimerDelegate, UIPopoverControllerDelegate, CBPeripheralManagerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;

@property (nonatomic, retain)IBOutlet UILabel *bpmLabel;

@property (nonatomic, retain)IBOutlet UISegmentedControl *signature;

@property (nonatomic, retain)IBOutlet UIStepper *stepper;

@property (nonatomic, strong)UIView *whiteScreen;

@property(nonatomic, strong)IBOutlet UISwitch *timerSwitch;

@property (nonatomic, strong) CBPeripheralManager *manager;

- (IBAction)changeBPM:(UIStepper*)stepper;
- (void)flashScreen;
- (void)beat;
- (IBAction)toggleTimer:(UISwitch*)toggle;
- (void) settingsViewControllerDidFinish:(Settings *)controller;
- (IBAction)changeSignature:(UISegmentedControl*)signature;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)matchBpm:(UIButton *)sender;

@end
