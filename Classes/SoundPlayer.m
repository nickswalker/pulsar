#import "SoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
@implementation SoundPlayer

- (void)playNormal
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Beat"
													 ofType:@"caf"];
	SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);
	
	
	
}
- (void)playAccent
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Accent"
													 ofType:@"caf"];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);

}
- (void)playDivision
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Division"
													 ofType:@"caf"];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);
	
}
- (void)playSubdivision
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Subdivision"
													 ofType:@"caf"];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);
	
}
- (void)playTriplet
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Triplet"
													 ofType:@"caf"];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);
	
}
- (void)vibrate
{
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	NSMutableArray* arr = [NSMutableArray array ];
	
	[arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for 2000ms
	[arr addObject:[NSNumber numberWithInt:150]];
	
	[dict setObject:arr forKey:@"VibePattern"];
	[dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
	
	
	AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}

@end
