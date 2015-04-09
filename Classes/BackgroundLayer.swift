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