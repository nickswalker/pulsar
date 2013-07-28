//
//  SignatureDisplay.m
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "BeatsControl.h"

@implementation BeatsControl
@synthesize numberOfDots = _numberOfDots,
	currentDot = _currentDot;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (self.numberOfDots ==12) self.numberOfDots = 1;
	self.numberOfDots++;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)drawRect:(CGRect)rect
{
	//NSLog(NSStringFromCGRect(rect));
	
	int xwidth = rect.size.width/self.numberOfDots;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	for (int i = 0; i < self.numberOfDots; i++) {
		CGRect tempRect = CGRectMake((i*xwidth), 0, xwidth, rect.size.height);
		CGPoint center = CGPointMake(CGRectGetMidX(tempRect), CGRectGetMidY(tempRect));
		
		CGRect tempCircleRect = CGRectMake(center.x-self.radius, center.y-self.radius, self.radius*2, self.radius*2);
	
		CGContextAddEllipseInRect(ctx, tempCircleRect);
		
		CGContextSetLineWidth(ctx, 1.0f);
		if (i+1 == self.currentDot) CGContextSetFillColor(ctx, CGColorGetComponents([self.tintColor CGColor])), CGContextSetStrokeColor(ctx, CGColorGetComponents([[UIColor clearColor] CGColor]));
		else CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor clearColor] CGColor])), CGContextSetStrokeColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
		CGContextFillEllipseInRect(ctx, tempCircleRect);
	
		CGContextStrokeEllipseInRect(ctx, tempCircleRect);
		
	}
   
}
#pragma mark - Getters and Setters

- (NSUInteger)numberOfDots	{
	return _numberOfDots;
}

- (void)setNumberOfDots:(NSUInteger)numberOfDots	{
	_numberOfDots = numberOfDots;
	[self setNeedsDisplay];
}
- (NSUInteger)currentDot	{
	return _currentDot;
}

- (void)setCurrentDot:(NSUInteger)currentDot	{
	_currentDot = currentDot;
	[self setNeedsDisplay];
}

@end
