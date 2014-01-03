#import <UIKit/UIKit.h>
#import "BeatControl.h"

@interface BeatsControl : UIControl

@property BeatControl* currentBeat;
@property NSUInteger radius;
@property NSArray* accents;
@property NSUInteger numberOfBeats;

- (bool)beatIsAccent:(NSUInteger)beat;
- (void)updateAccent:(BeatControl*)beat;
- (void)advanceBeat;
- (void)beat:(NSNotification *)notification;
- (void)addBeat;

@end
