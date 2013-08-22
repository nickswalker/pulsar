#import <Foundation/Foundation.h>
#import "DeltaTracker.h"
@interface Timer : NSObject

typedef enum{
	half,
	quarter,
	eigth,
	sixteenth,
	dottedQuarter,
	dottedEigth
}  BeatDenomination;

@property DeltaTracker* tracker;
@property bool on;
@property NSUInteger beatPartCount;
@property NSUInteger bpm;
@property NSArray* timeSignature;
@property BeatDenomination beatDenomination;

- (void) startTimer;
- (void) beat:(NSTimer*)timer;


@end
