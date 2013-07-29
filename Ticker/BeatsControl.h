//
//  SignatureDisplay.h
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeatControl.h"

@interface BeatsControl : UIControl

@property NSUInteger currentBeat;
@property NSUInteger numberOfBeats;
@property NSUInteger radius;
@property NSArray* accents;
@property UITapGestureRecognizer* tapRecognizer;
@property UIButton* backgroundButton;

- (void)handleTap:(UITapGestureRecognizer*)recognizer;
- (bool)beatIsAccent:(NSUInteger)beat;
- (void)updateAccent:(BeatControl*)beat;
@end
