//
//  TimerControl.m
//  Ticker
//
//  Created by Nick Walker on 7/29/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "bpmControl.h"
#import "Timer.h"

@implementation bpmControl

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.timeKeeper = [[Timer alloc] init];
//    }
//    return self;
//}
- (void) awakeFromNib
{
		
}
// Call when stepper value changes. Updates the text label and sends and event to propogate bpm change
-(IBAction)updateBPM:(UIStepper*)sender	{
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self];
	self.stepper.value = self.stepper.value - -1*translation.y/8.5;
	[recognizer setTranslation:CGPointMake(0, 0) inView:self];
	
	[self.stepper sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
