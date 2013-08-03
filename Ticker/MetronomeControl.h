//
//  MetronomeControl.h
//  Ticker
//
//  Created by Nick Walker on 7/29/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeSignatureControl.h"
#import "Timer.h"
#import "bpmControl.h"

@protocol MetronomeControlDelegate <NSObject>

@required
- (void)beat:(BeatControl*)beat denomination:(BeatDenomination)denomination part:(NSUInteger)part;

@end

@interface MetronomeControl : UIView


@property (weak, nonatomic) id <MetronomeControlDelegate> delegate;
@property IBOutlet bpmControl* bpmControl;
@property (nonatomic, retain)IBOutlet TimeSignatureControl* timeSignatureControl;
@property(nonatomic, strong)IBOutlet UISwitch *runningSwitch;
@property Timer* timeKeeper;

- (IBAction)toggleRunning:(UISwitch*)toggle;

@end
