//
//  timeBetween.m
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "deltaTracker.h"

@implementation deltaTracker
- (double)benchmark{
	if (self.startTime == 0) {
		self.startTime = [[NSDate date] timeIntervalSince1970];
		return 0;
	}
	else if (self.endTime == 0)	{
		self.endTime = [[NSDate date] timeIntervalSince1970];
	}
	else {
		self.startTime = self.endTime;
		self.endTime = [[NSDate date] timeIntervalSince1970];
	}
	return self.endTime-self.startTime;
}
- (void) clear	{
	
	self.startTime = 0;
	self.endTime = 0;
}
@end
