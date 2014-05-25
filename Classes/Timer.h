#import <Foundation/Foundation.h>
#import "DeltaTracker.h"
@interface Timer : NSObject

typedef enum{
	half = 2,
	quarter = 4,
	eigth = 8,
	sixteenth = 16,
	dottedQuarter = 0,
	dottedEigth = 0
}  BeatDenomination;

@property bool on;
@property NSUInteger bpm;
@property NSArray* timeSignature;
@property NSArray* accents;

@end
