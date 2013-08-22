#import <UIKit/UIKit.h>
#import "BeatsControl.h"
@interface TimeSignatureControl : UIControl

@property BeatsControl* topControl;
@property UISegmentedControl* bottomControl;
@property NSArray* timeSignature;

- (void) updateTimeSignature;
- (void) addBeat:(id)sender;
@end
