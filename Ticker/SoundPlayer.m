//
//  metronome.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

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
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
