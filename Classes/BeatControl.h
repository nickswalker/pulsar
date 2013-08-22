#import <UIKit/UIKit.h>

@interface BeatControl : UIControl

@property bool accent;
@property bool current;
@property NSUInteger number;
@property UILongPressGestureRecognizer* longPressRecognizer;
@property NSUInteger radius;

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer;
@end
