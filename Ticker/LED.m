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
	
	if ([device hasTorch] && [device hasFlash])
	{
		if (device.torchMode == AVCaptureTorchModeOff)
		{
			NSLog(@"It's currently off.. turning on now.");
			
			AVCaptureDeviceInput *flashInput = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
			AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
			
			AVCaptureSession *session = [[AVCaptureSession alloc] init];
			
			[session beginConfiguration];
			[device lockForConfiguration:nil];
			
			[device setTorchMode:AVCaptureTorchModeOn];
			[device setFlashMode:AVCaptureFlashModeOn];
			
			[session addInput:flashInput];
			[session addOutput:output];
			
			[device unlockForConfiguration];
			
			[session commitConfiguration];
			[session startRunning];
			
			[self setTorchSession:session];
		}
		else {
			
			NSLog(@"It's currently on.. turning off now.");
			[self.torchSession stopRunning];
		}
	}
}

@end
