import Foundation
import QuartzCore

@objc class DeltaTracker {
    var lastTime = 0.0
    func benchmark() -> (Double) {
        var currentTime = CACurrentMediaTime()
        let diff = currentTime - lastTime

        lastTime = currentTime // update for next call
        return diff
    }

}

func executionTimeInterval(block: () -> ()) -> CFTimeInterval {
    let start = CACurrentMediaTime()
    block();
    let end = CACurrentMediaTime()
    return end - start
}


