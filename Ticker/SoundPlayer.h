//
//  metronome.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundPlayer : NSObject

- (void) playTickSound;
- (void) playTockSound;
- (void) vibrate;
@end
