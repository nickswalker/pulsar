#import <UIKit/UIKit.h>
#import "Timer.h"

@interface bpmControl : UIControl

@property (nonatomic, retain)IBOutlet UILabel *bpmLabel;
@property (nonatomic, retain)IBOutlet UIStepper *stepper;

- (IBAction)updateBPM:(UIStepper*)stepper;
- (IBAction)handlePan:(UIPanGestureRecognizer*)recognizer;
@end
