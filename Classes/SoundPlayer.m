#import "SoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FISoundEngine.h"
#import "FISound.h"

@implementation SoundPlayer

FISound *beat;
FISound *division;
FISound *subdivision;
FISound *triplet;
FISound *accent;

+(void)loadSounds{
	
	NSError *error = nil;
	
	FISoundEngine *engine = [FISoundEngine sharedEngine];
	
	beat = [engine soundNamed:@"beat.wav" maxPolyphony:4 error:&error];
	division = [engine soundNamed:@"division.wav" maxPolyphony:4 error:&error];
	subdivision = [engine soundNamed:@"subdivision.wav" maxPolyphony:4 error:&error];
	triplet = [engine soundNamed:@"triplet.wav" maxPolyphony:4 error:&error];
	accent = [engine soundNamed:@"accent.wav" maxPolyphony:4 error:&error];

}

+ (void)playBeat
{
	[beat play];
}
+ (void)playAccent
{
	[accent play];
}
+ (void)playDivision
{
	[division play];
}
+ (void)playSubdivision
{
	[subdivision play];
}
+ (void)playTriplet
{
	[triplet play];
}
+ (void)vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	NSMutableArray* arr = [NSMutableArray array ];
	
	[arr addObject:[NSNumber numberWithBool:YES]];
	[arr addObject:[NSNumber numberWithInt:10]];
	
	[dict setObject:arr forKey:@"VibePattern"];
	[dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
	
	
	AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}

@end
