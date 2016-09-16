import Foundation
import QuartzCore

class DeltaTracker {
    var lastTime = 0.0
    func benchmark() -> (Double) {
        let currentTime = CACurrentMediaTime()
        let diff = currentTime - lastTime

        lastTime = currentTime // update for next call
        return diff
    }

}

func executionTimeInterval(_ block: () -> ()) -> CFTimeInterval {
    let start = CACurrentMediaTime()
    block()
    let end = CACurrentMediaTime()
    return end - start
}


