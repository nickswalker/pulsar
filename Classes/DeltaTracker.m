//
//  timeBetween.m
//  Ticker
//
//  Created by Nick Walker on 7/27/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "DeltaTracker.h"
#include <mach/mach_time.h>

@implementation DeltaTracker

- (double)benchmark{
	static double lastTime = 0;

	double currentTime = CACurrentMediaTime() ;
	
	double diff = currentTime - lastTime ;
	
	lastTime = currentTime ; // update for next call
	return diff ;
}

@end
