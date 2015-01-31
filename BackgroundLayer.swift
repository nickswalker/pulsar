//
//  BackgroundLayer.swift
//  pulsar
//
//  Created by Nick Walker on 1/30/15.
//  Copyright (c) 2015 Nick Walker. All rights reserved.
//

import Foundation
import QuartzCore

class BackgroundLayer: CALayer {

    override func containsPoint(p: CGPoint) -> Bool {
        return false;
    }
    override func hitTest(p: CGPoint) -> CALayer! {
        return nil;
    }
}