//
//  Flash.m
//  Ticker
//
//  Created by Nick Walker on 7/25/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "LED.h"

@implementation LED

- (void) toggleTorch
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ([device hasTorch]) {
		[device lockForConfiguration:nil];
		[device setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
		[device unlockForConfiguration];
	}
	[device lockForConfiguration:nil];
	[device setTorchMode:AVCaptureTorchModeOff];  // use AVCaptureTorchModeOff to turn off
	[device unlockForConfiguration];
}

@end
