//
//  FlipsideViewController.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
@required
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UITableViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property IBOutlet UISwitch* vibrationControl;
@property IBOutlet UISwitch* flashControl;
- (IBAction)done:(id)sender;
-(IBAction)toggleFlashing:(UISwitch*)flashingSwitch;
-(IBAction)toggleVibration:(UISwitch*)vibrationSwitch;
@end
