//
//  AccentsControl.h
//  Ticker
//
//  Created by Nick Walker on 7/28/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccentsControl : UIControl

@property NSUInteger numberOfDots;
@property NSUInteger radius;
@property NSMutableArray* accents;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
