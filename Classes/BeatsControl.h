#import <UIKit/UIKit.h>
#import "BeatControl.h"

@interface BeatsControl : UIControl

@property BeatControl* currentBeat;
@property NSArray* accents;
@property NSUInteger numberOfBeats;

- (void)advanceBeat;
- (void)clearDisplay;

@end
