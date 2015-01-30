#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <pthread.h>
#include "TimerDriver.h"
#import "Pulsar-Swift.h"

@implementation TimerDriver : NSObject 

- (instancetype) init:(id)delegate {
    self.delegate = delegate;
    return self;
}

-(void) beginOperation
{
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    int             returnVal;

    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);

    int threadError = pthread_create(&_thread, &attr, &timerLoop, (__bridge void *)(self));
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &returnVal);

    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
        // Report an error.
    }
}

- (void) cancel {
    pthread_cancel(_thread);
}

static void *timerLoop(void *context) {
    TimerDriver *self = (__bridge TimerDriver *)context;
    uint64_t currentTime;
    uint64_t targetTime;
    uint64_t waitTime;
    static mach_timebase_info_data_t    timebaseInfo;
    const uint64_t NANOS_PER_SEC = 1000000000ULL;

    if ( timebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&timebaseInfo);
    }

    double clock2abs = ((double)timebaseInfo.denom / (double)timebaseInfo.numer) * NANOS_PER_SEC;
    requestRealTimeScheduling();
    while (true) {
        // Loop until cancelled.
        //Notify the main thread that an interval has passed
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate interval];
        });

        // Do the maths. We hope that the multiplication doesn't
        // overflow; the price you pay for working in fixed point.

        currentTime =  mach_absolute_time();
        waitTime = [self.delegate intervalTime] *  clock2abs;
        targetTime = currentTime + waitTime;

        //Block here until currentTime is later than the targetTime
        while (currentTime < targetTime) {
            pthread_testcancel();
            usleep(10000);
            currentTime = mach_absolute_time();
        };
    }
}

void requestRealTimeScheduling()
{
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);

    const uint64_t NANOS_PER_MSEC = 1000000ULL;
    double clock2abs = ((double)timebase_info.denom / (double)timebase_info.numer) * NANOS_PER_MSEC;

    thread_time_constraint_policy_data_t policy;
    policy.period      = 0;
    policy.computation = (uint32_t)(5 * clock2abs); // 5 ms of work
    policy.constraint  = (uint32_t)(10 * clock2abs);
    policy.preemptible = FALSE;

    int kr = thread_policy_set(pthread_mach_thread_np(pthread_self()),
                               THREAD_TIME_CONSTRAINT_POLICY,
                               (thread_policy_t)&policy,
                               THREAD_TIME_CONSTRAINT_POLICY_COUNT);
    if (kr != KERN_SUCCESS) {
        mach_error("thread_policy_set:", kr);
        exit(1);
    }
}

@end