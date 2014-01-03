#import <Foundation/Foundation.h>

@interface SoundPlayer : NSObject

+ (void) loadSounds;
+ (void) playBeat;
+ (void) playAccent;
+ (void) playDivision;
+ (void) playSubdivision;
+ (void) playTriplet;
+ (void) vibrate;
@end
