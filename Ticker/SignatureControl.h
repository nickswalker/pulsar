//
//  SignatureDisplay.h
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureControl : UIControl

@property int currentDot;
@property int numberOfDots;
@property int radius;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
