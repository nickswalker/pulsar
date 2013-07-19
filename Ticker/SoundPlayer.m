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

-(void)playTickSound
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"tick"
													 ofType:@"caf"];
	SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	
	
}
-(void)playTockSound
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"tock"
													 ofType:@"caf"];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path])
									 , &soundID);
	AudioServicesPlaySystemSound (soundID);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
	


@end
