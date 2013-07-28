//
//  SignatureDisplay.h
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeatsControl : UIControl

@property NSUInteger currentDot;
@property NSUInteger numberOfDots;
@property NSUInteger radius;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
