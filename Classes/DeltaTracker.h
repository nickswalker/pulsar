#import <Foundation/Foundation.h>

@interface DeltaTracker : NSObject

@property NSUInteger numberOfBenchmarks;

- (double)benchmark;
@end
