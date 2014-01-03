#import "bpmControl.h"
#import "Timer.h"

@implementation BPMControl

UILabel *bpmLabel;
UIStepper *stepper;
UIPanGestureRecognizer* recognizer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		recognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:recognizer];
		
		bpmLabel = [[UILabel alloc] initWithFrame:  CGRectMake(0, 0, self.frame.size.width, 72)];
		bpmLabel.textColor = [UIColor whiteColor];
		bpmLabel.textAlignment = NSTextAlignmentCenter;
		bpmLabel.font =  [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:96];
		bpmLabel.text = @"60";
		[self addSubview:bpmLabel];
		
		stepper = [[UIStepper alloc] initWithFrame:  CGRectMake(self.frame.size.width/2 -94/2, 96,0 , 0)];
		stepper.minimumValue = 20;
		stepper.maximumValue = 300;
		stepper.value = 60;
		[stepper addTarget:self action:@selector(userChangedBPM:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:stepper];
    }
    return self;
}

- (void)userChangedBPM:(UIStepper*)sender	{
	bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(NSUInteger) bpm	{
	return stepper.value;
}
-(void) setBpm:(NSUInteger)bpm	{
	stepper.value = bpm;
	bpmLabel.text = [NSString stringWithFormat:@"%d", (int)stepper.value];
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:self];
	self.bpm = self.bpm - -1*translation.y/8.5;
	[recognizer setTranslation:CGPointMake(0, 0) inView:self];
	//	if (recognizer.state == UIGestureRecognizerStateEnded) {
	//
	//		float velocity = [recognizer velocityInView:self.view].y;
	//		NSLog(@"%f",velocity);
	//		float slideFactor = 0.1; // Increase for more of a slide
	//		int finalValue = self.controls.bpm + slideFactor * velocity;
	//		[UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
	//			self.controls.bpm = finalValue;
	//		} completion:nil];
	//
	//	}
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
