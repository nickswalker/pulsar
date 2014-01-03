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
		self.longPressRecognizer.minimumPressDuration = .2;
		 [self addGestureRecognizer:self.longPressRecognizer];
    }
    return self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
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
	
	NSUInteger accentRadius = 2;
	
	if (self.current){
		CGContextSetFillColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
		CGContextSetStrokeColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
	}
//	else if(self.division){
//		static CGFloat const kDashedPhase           = (0.0f);
//		static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
//		static size_t const kDashedCount            = (2.0f);
//		  CGContextSetLineDash(ctx, kDashedPhase, kDashedLinesLength, kDashedCount) ;
//	}
	CGContextFillEllipseInRect(ctx, tempCircleRect);
	CGContextStrokeEllipseInRect(ctx, tempCircleRect);
	
	if (self.accent){
		CGRect tempAccentCircleRect = CGRectMake(center.x-accentRadius, center.y-accentRadius, accentRadius*2, accentRadius*2);
		
		CGContextSetFillColor(ctx, CGColorGetComponents([self.tintColor CGColor]));
		CGContextFillEllipseInRect(ctx, tempAccentCircleRect);
	}
	
	

}
#pragma mark - Getters and Setters
- (void)setCurrent:(bool)current	{
	_current = current;
	[self setNeedsDisplay];
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
