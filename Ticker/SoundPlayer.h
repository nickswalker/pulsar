//
//  metronome.h
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundPlayer : NSObject

- (void) playNormal;
- (void) playAccent;
- (void) playDivision;
- (void) playSubdivision;
- (void) playTriplet;
- (void) vibrate;
@end
