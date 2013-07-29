//
//  BeatControl.h
//  Ticker
//
//  Created by Nick Walker on 7/28/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeatControl : UIControl

@property bool accent;
@property bool current;
@property NSUInteger number;
@property UILongPressGestureRecognizer* longPressRecognizer;
@property NSUInteger radius;

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer;
@end
