import Foundation

let maxBPM = 300
let minBPM = 20
let partsPerBeat = 12
let secondsInMinute = 60


public enum BeatPartMeanings: UInt16 {
    case OnTheBeat = 0b10,
         Division = 0b10000000,
         SubDivision = 0b10000010000,
         Triplet = 0b1000100010
}

//Beats one measure and all possible sub intervals for a BPM

public class Timer: IntervalDelegate {

    @objc public func intervalTime() -> Double {
        return intervalDuration
    }
    var on: Bool = false {
        willSet(newValue) {
            if newValue {
                start()
            } else {
                stop()
            }
        }
    }

    var bpm: Int = 60 {
        willSet(newValue) {
            if newValue > maxBPM {
                self.bpm = maxBPM
            } else if newValue < minBPM {
                self.bpm = minBPM
            }
        }
    }

    // In milliseconds
    var intervalDuration: Double {
        get {
            return 60.0 / (Double(bpm) * Double(partsPerBeat))
        }
    }
    var currentBeatPart = 0
    var timerDriver: TimerDriver?

    init() {
    }



    func start() {
        stop()
        timerDriver = TimerDriver(self)
        timerDriver!.beginOperation()
    }


    func stop() {
        if timerDriver != nil {
            timerDriver!.cancel()
            timerDriver = nil
        }
        currentBeatPart = 0
        timerDriver = nil
    }

    @objc public func interval() {
        var accent = false
        if currentBeatPart > partsPerBeat {
            currentBeatPart = 1
        }

        let part: Int = 1 << (currentBeatPart)
        NSNotificationCenter.defaultCenter().postNotificationName("interval", object: nil, userInfo: ["beatPart": part])
        currentBeatPart++
    }


}