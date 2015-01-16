import Foundation
import UIKit
import QuartzCore
import LabeledSlideStepper

let accentOnFirstBeat = [1]

class MetronomeViewController: UIViewController, SettingsDelegate,
        LabeledSlideStepperDelegate, QuickSettingsDelegate, SessionCreationDelegate, ShardControlDelegate {

    @IBOutlet var bpmControl: LabeledSlideStepper?
    @IBOutlet var beatsControl: ShardControl?
    @IBOutlet var quickSettingsButton: UIButton?
    @IBOutlet var settingsButton: UIButton?
    @IBOutlet var sessionButton: UIButton?

    var quickSettings: QuickSettingsViewController?
    var sessionController: SessionViewController?
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var defaults = NSUserDefaults.standardUserDefaults()
	var opacityAnimation: () -> () = {}
	var commonSignaturesIndex: Int? = nil {
        willSet(newValue){
            if newValue != nil {
                if newValue > Configuration.commonConfigurations.count - 1 {
                    self.commonSignaturesIndex = 0
                }
                let config = Configuration.commonConfigurations[newValue!]
                beatsControl!.numberOfShards = config.beats
            }
        }
    }

    private var running: Bool = false {
        willSet(newValue){
            if newValue == true {
                timer.start()
                bpmControl!.running = true
                UIApplication.sharedApplication().idleTimerDisabled = true

            } else {
                beatsControl!.activeShard = nil
                timer.stop()
                bpmControl!.running = false
                UIApplication.sharedApplication().idleTimerDisabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        opacityAnimation  = {
            self.view.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        }
        var path = NSBundle.mainBundle().pathForResource("CommonTimeSignatures", ofType: "plist")
        bpmControl!.delegate = self

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
        let accents = UInt(defaults.integerForKey("accents"))
        beatsControl!.activated = accents
        beatsControl!.delegate = self

        let bpm = defaults.integerForKey("bpm")
        bpmControl!.bpm = bpm
        timer.bpm = bpm

        setupSessionEventHandlers()

    }

    override func viewDidAppear(animated: Bool) {
        beatsControl!.frame = view.frame
        let halfWidth = CGRectGetMidX(UIScreen.mainScreen().bounds)
        let halfHeight = CGRectGetMidY(UIScreen.mainScreen().bounds)
        let radius = hypot(halfWidth, halfHeight)

        beatsControl!.radius = radius
    }

    //@discussion listens to the timer emitting beatParts.
    func intervalWasFired(notification: NSNotification) {
        // FIXME: This is going to need to be faster. Too much branching
        let part = notification.userInfo!["beatPart"] as Int
        let beatPart:UInt16 = UInt16(part)
        if (beatPart & BeatPartMeanings.OnTheBeat.rawValue) > 0 {
            beatsControl!.activateNext()
            if defaults.boolForKey("beat") {
                SoundPlayer.playBeat()
            }
            if defaults.boolForKey("screenFlash") {
                beatsControl?.flashBackground()
            }
            if defaults.boolForKey("ledFlash") {
                LED.flash()
            }
            if beatsControl!.activeIsAccent() {
                SoundPlayer.playAccent()
                beatsControl!.flashBackground()
            }
        } else if (beatPart & BeatPartMeanings.Division.rawValue) > 0 {
            if defaults.boolForKey("division") {
                SoundPlayer.playDivision()
            }
        } else if (beatPart & BeatPartMeanings.SubDivision.rawValue) > 0 {
            if defaults.boolForKey("subdivision") {
                SoundPlayer.playSubdivision()
            }
        } else if (beatPart & BeatPartMeanings.Triplet.rawValue) > 0 {
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

    //MARK: Gestures

    private let maxTimeBetweenTaps = 20.0

    @IBAction func matchBpm(sender: AnyObject) {
        var delta = bpmTracker.benchmark()
        if delta == 0 {
            return
        } else if ((Double(secondsInMinute) / delta) < maxTimeBetweenTaps) {
            return
        }
        bpmControl!.bpm = Int(Double(secondsInMinute) / (delta))
    }

    @IBAction func cycleTimeSignature(sender: AnyObject) {
        let delta = timeSignatureTracker.benchmark()
        if delta > 2 {
            commonSignaturesIndex = 0
        }
        commonSignaturesIndex!++

    }
    @IBAction func didSwipeLeft(){
        beatsControl!.numberOfShards--
        defaults.setInteger(beatsControl!.numberOfShards, forKey: "beats")
    }
    @IBAction func didSwipeRight(){
        beatsControl!.numberOfShards++
        defaults.setInteger(beatsControl!.numberOfShards, forKey: "beats")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            running = false

            let viewControllers = segue.destinationViewController.viewControllers as Array
            let settingsViewController = viewControllers[0] as SettingsViewController
            settingsViewController.delegate = self
            settingsViewController.screenFlashControl!.on = defaults.boolForKey("screenFlash")
            settingsViewController.ledFlashControl!.on = defaults.boolForKey("ledFlash")
            settingsViewController.digitalVoiceControl!.on = defaults.boolForKey("digitalVoice")
        }
    }

    // MARK: Overlays

    @IBAction func presentSessionController() {
        let window = UIApplication.sharedApplication().keyWindow!
        sessionController = SessionViewController()
        bpmControl!.tintAdjustmentMode = .Dimmed
        sessionController!.delegate = self
        window.addSubview(sessionController!.view)
        sessionController!.animateIn()
    }

    @IBAction func presentQuickSettings() {
        let window = UIApplication.sharedApplication().keyWindow!
        bpmControl!.tintAdjustmentMode = .Dimmed
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
        bpmControl!.tintAdjustmentMode = .Normal
        sessionController = nil
        if !sessionCreated {
            ConnectionManager.stop()
        }
        else if initiated {
            let initialConfig: [String: MPCSerializable] = ["bpm": MPCInt(value: self.bpmControl!.bpm), "beats": MPCInt(value: beatsControl!.numberOfShards)]
            ConnectionManager.sendEvent(.StartSession, object: initialConfig)
            ConnectionManager.sendEvent(.Start, object: ["hello": MPCInt(value: 10)])
        }

    }

    func settingsViewControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func quickSettingsViewControllerDidFinish() {
        bpmControl!.tintAdjustmentMode = .Normal
        quickSettings = nil
    }

    func settingChangedForKey(key: String, value: AnyObject) {
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }

    func activatedShardsChanged() {
        defaults.setInteger(Int(beatsControl!.activated), forKey: "accents")
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
            self.bpmControl!.bpm = bpm
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
            self.bpmControl!.bpm = bpm
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