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
	
	double currentTime = machGetClockS() ;
	
	double diff = currentTime - lastTime ;
	
	lastTime = currentTime ; // update for next call
	return diff ; // that's your answe

}
double machGetClockS()
{
	static bool init = false ;
	static mach_timebase_info_data_t tbInfo ;
	static double conversionFactor ;
	if(!init)
	{
		// get the time base
		mach_timebase_info( &tbInfo ) ;
		conversionFactor = tbInfo.numer / (1e9*tbInfo.denom) ; // ns->s
	}
	
	return mach_absolute_time() * conversionFactor ; // seconds
}
@end
