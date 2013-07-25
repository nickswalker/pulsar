//
//  Flash.h
//  Ticker
//
//  Created by Nick Walker on 7/25/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LED : NSObject

@property (nonatomic, retain) AVCaptureSession * torchSession;

- (void) toggleTorch;
	
@end
