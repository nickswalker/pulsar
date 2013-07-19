//
//  MainViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SoundPlayer.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (nonatomic, retain)IBOutlet UILabel *bpmLabel;

@property (nonatomic, retain)IBOutlet UISegmentedControl *signature;

@property (nonatomic, retain)IBOutlet UIStepper *stepper;

@property (nonatomic, strong)UIView *whiteScreen;

@property(nonatomic)BOOL isRunning;

-(void) beat:(NSTimer*)timer;
-(IBAction)changeBPM:(UIStepper*)stepper;
-(void) updateCount;
-(void) flashScreen;
-(void) startTimer;
-(void) stopTimer;
-(IBAction)toggleTimer:(UISwitch*)toggle;
@end
