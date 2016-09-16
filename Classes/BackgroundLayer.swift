import Foundation
import QuartzCore

class BackgroundLayer: CALayer {

    override func contains(_ p: CGPoint) -> Bool {
        return false;
    }
    override func hitTest(_ p: CGPoint) -> CALayer? {
        return nil;
    }
}
