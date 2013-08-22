#import <UIKit/UIKit.h>
#import "BeatControl.h"

@interface BeatsControl : UIControl

@property BeatControl* currentBeat;
@property NSUInteger numberOfBeats;
@property NSUInteger radius;
@property NSArray* accents;
@property UITapGestureRecognizer* tapRecognizer;
@property UIButton* backgroundButton;
@property NSArray* timeSignature;

- (bool)beatIsAccent:(NSUInteger)beat;
- (void)updateAccent:(BeatControl*)beat;
- (void)advanceBeat;
@end
