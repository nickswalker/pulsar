//
//  MainViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Settings.h"
#import "MetronomeControl.h"
@class BeatControl, Timer;
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface Metronome : UIViewController <SettingsViewControllerDelegate, MetronomeControlDelegate, UIPopoverControllerDelegate>

@property DeltaTracker* tracker;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property MCPeerID* peerID;
@property MCSession* session;
@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (nonatomic, strong)IBOutlet UIButton *backgroundButton;
@property IBOutlet MetronomeControl* controls;


- (IBAction)matchBpm:(id)sender;
- (IBAction)cycleTimeSignature:(id)sender;
- (void)flashScreen;
- (void)beat:(BeatsControl*)beat denomination:(BeatDenomination)denomination part:(NSUInteger)part;
- (void)setSettingsFromDefaults:(MetronomeControl*)target;
- (void)settingsViewControllerDidFinish:(Settings *)controller;
- (void)syncSettingsChangesToDefaults;

@end
