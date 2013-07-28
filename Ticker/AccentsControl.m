//
//  AccentsControl.m
//  Ticker
//
//  Created by Nick Walker on 7/28/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "AccentsControl.h"

@implementation AccentsControl
@synthesize numberOfDots = _numberOfDots;
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
		if ([self beatIsAccent:i]) CGContextSetFillColor(ctx, CGColorGetComponents([self.tintColor CGColor])), CGContextSetStrokeColor(ctx, CGColorGetComponents([[UIColor clearColor] CGColor]));
		else CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor clearColor] CGColor])), CGContextSetStrokeColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
		CGContextFillEllipseInRect(ctx, tempCircleRect);
		
		CGContextStrokeEllipseInRect(ctx, tempCircleRect);
		
	}
	
}
-(bool)beatIsAccent:(int)beat{
	self.accents = [@[@NO,@NO,@YES,@YES,@NO,@NO,@NO,@NO,@NO,@NO,@NO,@NO] mutableCopy];
	NSNumber* searchBeat = [NSNumber numberWithInt:beat];
	for (searchBeat in self.accents) {

	}
	return true;
}
#pragma mark - Getters and Setters

- (NSUInteger)numberOfDots	{
	return _numberOfDots;
}

- (void)setNumberOfDots:(NSUInteger)numberOfDots	{
	_numberOfDots = numberOfDots;
	[self setNeedsDisplay];
}


@end
