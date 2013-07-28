//
//  TimeSignatureControl.h
//  Ticker
//
//  Created by Nick Walker on 7/28/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeatsControl.h"
@interface TimeSignatureControl : UIControl

@property BeatsControl* topControl;
@property UISegmentedControl* bottomControl;
@property NSDictionary* timeSignature;

- (void) updateTimeSignature:(id)sender;
@end
