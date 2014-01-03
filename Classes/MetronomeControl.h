#import <UIKit/UIKit.h>

@interface MetronomeControl : UIView

@property NSUInteger bpm;
@property NSArray* timeSignature;
@property BOOL running;

- (void)syncSettingsChangesToDefaults;
- (void)setSettingsFromDefaults;

@end
