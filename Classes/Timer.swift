import Foundation

let maxBPM = 300
let minBPM = 20
let partsPerBeat = 12
let secondsInMinute = 60
// FIXME: Beat part meanings. This might work as a class. The timer would emit beatPart objects that have .divison .subdivision .triplet set
let onTheBeat = [1]
let division = [7]
let subDivision = [4, 10]
let triplet = [1, 5, 9]
//Beats one measure and all possible sub intervals for a BPM

// FIXME: Has to have objc attribute or NSThread methods won't be able to see it

@objc public class Timer {

    var on: Bool = false {
        willSet(newValue) {
            if (newValue) {
                //self.startTimer()
            } else {
                //self.stopTimer()
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

    var intervalDuration: Double {
        get {
            return ((60.0) / Double(bpm)) / Double(partsPerBeat)
        }
    }
    var currentBeatPart = 0
    var timerThread: NSThread?

    init() {
    }

    // This method is invoked from the driver thread
    func startBackgroundTimerOperation() {
        // Give the sound thread high priority to keep the timing steady.
        NSThread.setThreadPriority(1.0)
        var continuePlaying = true
        var currentTime = NSDate()

        while (NSThread.currentThread().cancelled == false) {
            // Loop until cancelled.
            //Notify the main thread that an interval has passed
            dispatch_async(dispatch_get_main_queue(), {
                self.interval()
            })
            var targetTime = NSDate(timeIntervalSinceNow: self.intervalDuration)
            currentTime = NSDate()

            //Block here until currentTime is later than the targetTime
            while continuePlaying && (currentTime.compare(targetTime) != NSComparisonResult.OrderedDescending) {
                if (NSThread.currentThread().cancelled == true) {
                    continuePlaying = false
                }
                NSThread.sleepForTimeInterval(0.001)
                currentTime = NSDate()
            }
        }
        NSThread.exit()
    }

    func start() {
        stop()
        timerThread = NSThread(target: self, selector: "startBackgroundTimerOperation", object: nil)
        timerThread!.start()
    }

    func stop() {
        if timerThread != nil {
            timerThread!.cancel()
        }
        currentBeatPart = 0
        timerThread = nil
    }

    public func interval() {
        var accent = false
        if currentBeatPart > partsPerBeat {
            currentBeatPart = 1
        }
        NSNotificationCenter.defaultCenter().postNotificationName("interval", object: nil, userInfo: ["beatPart": currentBeatPart])
        currentBeatPart++
    }


}