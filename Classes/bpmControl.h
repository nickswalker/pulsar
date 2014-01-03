#import <UIKit/UIKit.h>

@interface BPMControl : UIControl

@property (nonatomic, retain) UILabel *bpmLabel;
@property (nonatomic, retain)UIStepper *stepper;
@property NSUInteger bpm;

@end
