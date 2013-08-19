//
//  TimerControl.h
//  Ticker
//
//  Created by Nick Walker on 7/29/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timer.h"

@interface bpmControl : UIControl

@property (nonatomic, retain)IBOutlet UILabel *bpmLabel;
@property (nonatomic, retain)IBOutlet UIStepper *stepper;

- (IBAction)updateBPM:(UIStepper*)stepper;
- (IBAction)handlePan:(UIPanGestureRecognizer*)recognizer;
@end
