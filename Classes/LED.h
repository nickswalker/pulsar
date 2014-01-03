#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LED : NSObject

@property (nonatomic, retain) AVCaptureSession * torchSession;

+ (void) toggleTorch;
	
@end
