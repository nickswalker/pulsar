#import "LED.h"

@implementation LED

- (void) toggleTorch
{
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) {
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		if ([device hasTorch]) {
			[device lockForConfiguration:nil];
			[device setTorchModeOnWithLevel:.1 error:nil];
			[device unlockForConfiguration];
		}
		[device lockForConfiguration:nil];
		[device setTorchMode:AVCaptureTorchModeOff];
		[device unlockForConfiguration];
	}
}

@end
