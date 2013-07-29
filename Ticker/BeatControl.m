//
//  BeatControl.m
//  Ticker
//
//  Created by Nick Walker on 7/28/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "BeatControl.h"

@implementation BeatControl
@synthesize current = _current,
accent = _accent;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
		 [self.longPressRecognizer addTarget:self action:@selector(handleLongPress:)];
		 [self addGestureRecognizer:self.longPressRecognizer];
    }
    return self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer	{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		if (self.accent==false) self.accent = true;
		else self.accent = false;
	}
		
}
	
- (void)drawRect:(CGRect)rect
{
	self.radius = 5;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	
	CGRect tempCircleRect = CGRectMake(center.x-self.radius, center.y-self.radius, self.radius*2, self.radius*2);
	
	CGContextAddEllipseInRect(ctx, tempCircleRect);
	
	CGContextSetLineWidth(ctx, 1.0f);
	
	CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor clearColor] CGColor]));
	CGContextSetStrokeColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
	
	if(self.accent){
		CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:.15f] CGColor]));
	}
	if (self.current){
		CGContextSetFillColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
		CGContextSetStrokeColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
	}
	
	
	CGContextFillEllipseInRect(ctx, tempCircleRect);
	CGContextStrokeEllipseInRect(ctx, tempCircleRect);

}
#pragma mark - Getters and Setters
- (void)setCurrent:(bool)current	{
	_current = current;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
- (bool)current{
	return _current;
}
- (void)setAccent:(bool)accent{
	_accent = accent;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
- (bool)accent{
	return _accent;
}
@end
