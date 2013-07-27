//
//  MainViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Settings.h"
#import "Timer.h"
#import "SignatureControl.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Metronome : UIViewController <SettingsViewControllerDelegate, TimerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;

@property (nonatomic, retain)IBOutlet UILabel *bpmLabel;

@property (nonatomic, retain)IBOutlet UISegmentedControl *signatureBottom;

@property (nonatomic, retain)IBOutlet SignatureControl *signatureTop;

@property (nonatomic, retain)IBOutlet UIStepper *stepper;

@property (nonatomic, strong)IBOutlet UIButton *backgroundButton;

@property(nonatomic, strong)IBOutlet UISwitch *timerSwitch;


- (IBAction)updateBPM:(UIStepper*)stepper;
- (IBAction)updateTimeSignature:(id)sender;
- (IBAction)toggleTimer:(UISwitch*)toggle;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)matchBpm:(UIButton *)sender;
- (IBAction)cycleTimeSignature:(id)sender;
- (void)flashScreen;
- (void)beat;
- (void) settingsViewControllerDidFinish:(Settings *)controller;
- (void)changeTimeSignature:(NSDictionary*)timeSignature;


@end
