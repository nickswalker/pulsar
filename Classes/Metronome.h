#import "Settings.h"
#import "MetronomeControl.h"
#import "Timer.h"
@class BeatControl, DeltaTracker;
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "GAITrackedViewController.h"

@interface Metronome : GAITrackedViewController <SettingsViewControllerDelegate>

@property DeltaTracker* timeTracker;
@property MCPeerID* peerID;
@property MCSession* session;
@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (nonatomic, strong)IBOutlet UIButton *backgroundButton;
@property IBOutlet MetronomeControl* controls;

//Gestures
- (IBAction)matchBpm:(id)sender;
- (IBAction)cycleTimeSignature:(id)sender;

- (void)flashScreen;
- (void)beat:(NSNotification*)notification;
- (void)settingsViewControllerDidFinish:(Settings *)controller;


@end
