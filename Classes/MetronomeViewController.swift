import Foundation
import UIKit
import QuartzCore
import MetronomeControl

typealias TimeSignature = MetronomeControl.TimeSignature
typealias NoteValue = MetronomeControl.NoteValue

let accentOnFirstBeat = [1]

class MetronomeViewController: UIViewController, SettingsDelegate,
        MetronomeControlDelegate, QuickSettingsDelegate, SessionCreationDelegate {

    @IBOutlet var backgroundButton: UIButton?
    @IBOutlet var controls: MetronomeControl?
    @IBOutlet var beatsControl: ShardControl?
    @IBOutlet var quickSettingsButton: UIButton?
    @IBOutlet var settingsButton: UIButton?
    @IBOutlet var sessionButton: UIButton?

    var quickSettings: QuickSettingsViewController?
    var sessionController: SessionViewController?
    var led = LED()
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var commonTimeSignatures: [AnyObject]!
    var defaults = NSUserDefaults.standardUserDefaults()
    var commonSignaturesIndex = 0

    private var running: Bool = false {
        willSet(newValue){
            if newValue == true {
                timer.start()
                controls!.running = true
                UIApplication.sharedApplication().idleTimerDisabled = true

            } else {
                beatsControl!.activeShard = nil
                timer.stop()
                controls!.running = false
                UIApplication.sharedApplication().idleTimerDisabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var path = NSBundle.mainBundle().pathForResource("CommonTimeSignatures", ofType: "plist")
        commonTimeSignatures = NSArray(contentsOfFile: path!)!
        controls!.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "intervalWasFired:",
                                                         name: "interval",
                                                         object: nil)
        //This gets fired whenever changes occur in QuickSettings
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSettingsFromUserDefaults", name:
        NSUserDefaultsDidChangeNotification, object: nil)
        defaults = NSUserDefaults.standardUserDefaults()

        let beats = defaults.integerForKey("beats")
        beatsControl!.numberOfShards = beats

        let bpm = defaults.integerForKey("bpm")
        controls!.bpm = bpm

        setupSessionEventHandlers()

    }

    override func viewDidAppear(animated: Bool) {
        beatsControl!.frame = view.frame
        beatsControl!.layer.layoutSublayers()
    }

    //@discussion listens to the timer emitting beatParts.
    func intervalWasFired(notification: NSNotification) {
        // FIXME: This is going to need to be faster. Too much branching
        let part: Int = Int(notification.userInfo?["beatPart"] as NSNumber)
        if find(onTheBeat, part) != nil {
            beatsControl!.activateNext()
            if defaults.boolForKey("beat") {
                SoundPlayer.playBeat()
            }
            if defaults.boolForKey("screenFlash") {
                flashScreen()
            }
            if beatsControl!.activeIsAccent() {
                SoundPlayer.playAccent()
                flashScreen()
            }
        } else if find(division, part) != nil {
            if defaults.boolForKey("division") {
                SoundPlayer.playDivision()
            }
        } else if find(subDivision, part) != nil {
            if defaults.boolForKey("subdivision") {
                SoundPlayer.playSubdivision()
            }
        } else if find(triplet, part) != nil {
            if defaults.boolForKey("triplet") {
                SoundPlayer.playTriplet()
            }
        }

    }

    //MARK: MetronomeControlDelegate

    func bpmChanged(sender: SlideStepper) {
        timer.bpm = sender.value
        defaults.setObject(sender.value, forKey: "bpm")
        defaults.synchronize()
        if ConnectionManager.inSession {
            let change: [String: MPCSerializable] = ["bpm": MPCInt(value: sender.value)]
            ConnectionManager.sendEvent(.ChangeBPM, object: change)
        }
    }

    func switchToggled(sender: UISwitch) {
        running = sender.on

        if ConnectionManager.inSession {
            let event: Event = sender.on ? .Start : .Stop
            ConnectionManager.sendEvent(event, object: nil)
        }
    }

    func updateSettingsFromUserDefaults() {
        //The defaults were changed externally: pull in the changes
        defaults.synchronize()
        let beats = defaults.integerForKey("beats")
        if beats != beatsControl!.numberOfShards {
            beatsControl!.numberOfShards = beats
            if ConnectionManager.inSession {
                let change: [String: MPCSerializable] = ["beats": MPCInt(value: beats)]
                ConnectionManager.sendEvent(.ChangeBeats, object: change)
            }
        }
    }



    private func flashScreen() {
        backgroundButton!.layer.opacity = 0.02
        backgroundButton!.backgroundColor = UIColor.whiteColor()
        let opacityAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0.0

        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = true
        opacityAnimation.duration = 0.10
        backgroundButton!.layer.addAnimation(opacityAnimation, forKey: "animation")
    }

    //MARK: Gesture Controls

    private let maxTimeBetweenTaps = 20.0

    @IBAction func matchBpm(sender: AnyObject) {
        var delta = bpmTracker.benchmark()
        if delta == 0 {
            return
        } else if ((Double(secondsInMinute) / delta) < maxTimeBetweenTaps) {
            return
        }
        controls!.bpm = Int(Double(secondsInMinute) / (delta))
    }

    @IBAction func cycleTimeSignature(sender: AnyObject) {
        let delta = timeSignatureTracker.benchmark()
        if delta > 2 {
            commonSignaturesIndex = 0
        }
        if commonSignaturesIndex > 6 {
            commonSignaturesIndex = 0
        }

        commonSignaturesIndex++

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            running = false

            let viewControllers = segue.destinationViewController.viewControllers as Array
            let settingsViewController = viewControllers[0] as SettingsViewController
            settingsViewController.delegate = self
        }
    }
    // MARK: Overlay Controls

    @IBAction func presentSessionController() {
        let window = UIApplication.sharedApplication().keyWindow!

        sessionController = SessionViewController()
        controls!.tintAdjustmentMode = .Dimmed
        sessionController!.delegate = self
        window.addSubview(sessionController!.view)
        sessionController!.animateIn()
    }

    @IBAction func presentQuickSettings() {
        let window = UIApplication.sharedApplication().keyWindow!
        controls!.tintAdjustmentMode = .Dimmed
        quickSettings = QuickSettingsViewController(nibName:"QuickSettingsPanel", bundle: NSBundle.mainBundle())

        quickSettings!.delegate = self
        window.addSubview(quickSettings!.view)
        quickSettings!.beatControl!.on = defaults.boolForKey("beat")
        quickSettings!.divisionControl!.on = defaults.boolForKey("division")
        quickSettings!.subdivisionControl!.on = defaults.boolForKey("subdivision")
        quickSettings!.tripletControl!.on = defaults.boolForKey("triplet")
        let beats = defaults.integerForKey("beats")
        quickSettings!.beatsControlLabel!.text = "\(beats)"
        quickSettings!.beatsControl!.value = Double(beats)
        quickSettings!.animateIn()
    }


    func sessionViewControllerDidFinish(sessionCreated: Bool, initiated: Bool){
        controls!.tintAdjustmentMode = .Normal
        sessionController = nil
        if !sessionCreated {
            ConnectionManager.stop()
        }
        else if initiated {
            let initialConfig: [String: MPCSerializable] = ["bpm": MPCInt(value: self.controls!.bpm), "beats": MPCInt(value: beatsControl!.numberOfShards)]
            ConnectionManager.sendEvent(.StartSession, object: initialConfig)
            ConnectionManager.sendEvent(.Start, object: ["hello": MPCInt(value: 10)])
        }

    }

    func settingsViewControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func quickSettingsViewControllerDidFinish() {
        controls!.tintAdjustmentMode = .Normal
        quickSettings = nil
    }

    func settingChangedForKey(key: String, value: AnyObject) {
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }

    // MARK: Appearance
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return .LightContent
    }

    // MARK: Sessions

    private func setupSessionEventHandlers(){
        ConnectionManager.onEvent(.StartSession, run: {
            peerID, object in
            let dict = object as [String: NSData]

            let bpm = MPCInt(mpcSerialized: dict["bpm"]!).value
            let beats = MPCInt(mpcSerialized: dict["beats"]!).value
            self.timer.bpm = bpm
            self.controls!.bpm = bpm
            self.beatsControl!.numberOfShards = beats
            if self.sessionController != nil {
                //This may cause a bug if the other person starts a session very soon after the first
                //person does. The SessionController will be already removed from the view or being animated.
                self.sessionController!.delegate?.sessionViewControllerDidFinish(true, initiated: false)
            }
        })
        ConnectionManager.onEvent(.ChangeBeats, run: {
            peerID, object in
            let dict = object as [String: NSData]

            let beats = MPCInt(mpcSerialized: dict["beats"]!).value
            self.beatsControl!.numberOfShards = beats
        })
        ConnectionManager.onEvent(.ChangeBPM, run: {
            peerID, object in
            let dict = object as [String: NSData]

            let bpm = MPCInt(mpcSerialized: dict["bpm"]!).value
            self.timer.bpm = bpm
            self.controls!.bpm = bpm
        })
        ConnectionManager.onEvent(.Start, run: {
            peerID, object in
            //Wait until a date in the future, then flip the switch
            self.running = true

        })
        ConnectionManager.onEvent(.Stop, run: {
            peerID, object in
            self.running = false
        })
    }
}