//
//  SignatureDisplay.m
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "SignatureControl.h"

@implementation SignatureControl
@synthesize numberOfDots = _numberOfDots,
	currentDot = _currentDot;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)awakeFromNib{
	self.radius = 5;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (self.numberOfDots ==12) self.numberOfDots = 1;
	++self.numberOfDots;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)drawRect:(CGRect)rect
{
	int xwidth = rect.size.width/self.numberOfDots;
	CGPoint origin = rect.origin;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	for (int i = 0; i<self.numberOfDots; i++) {
		CGRect tempRect = CGRectMake((i*xwidth), origin.y, xwidth, rect.size.height);
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

- (int)numberOfDots	{
	return _numberOfDots;
}

- (void)setNumberOfDots:(int)numberOfDots	{
	_numberOfDots = numberOfDots;
	[self setNeedsDisplay];
}
- (int)currentDot	{
	return _currentDot;
}

- (void)setCurrentDot:(int)currentDot	{
	_currentDot = currentDot;
	[self setNeedsDisplay];
}

@end
