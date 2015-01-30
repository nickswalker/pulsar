#import <Foundation/Foundation.h>
#import <pthread.h>

@protocol IntervalDelegate
    -(void) interval;
    -(double) intervalTime;
@end

@interface TimerDriver : NSObject

@property (nonatomic, assign) id <IntervalDelegate> delegate;
@property pthread_t thread;

- (instancetype) init:(id)delegate;
- (void)beginOperation;
- (void)cancel;
@end