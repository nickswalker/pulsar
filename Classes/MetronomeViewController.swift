import Foundation
import UIKit
import QuartzCore
import LabeledSlideStepper
import PeerKit

let accentOnFirstBeat = [1]

class MetronomeViewController: UIViewController, SettingsDelegate,
        LabeledSlideStepperDelegate, QuickSettingsDelegate, SessionCreationDelegate, ShardControlDelegate {

    @IBOutlet weak var bpmControl: LabeledSlideStepper!
    @IBOutlet weak var beatsControl: ShardControl!
    @IBOutlet weak var quickSettingsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var sessionButton: UIButton!

    var quickSettings: QuickSettingsViewController?
    var sessionController: SessionViewController?
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var defaults = NSUserDefaults.standardUserDefaults()
	var opacityAnimation: () -> () = {}
	var commonSignaturesIndex: Int? = nil {
        didSet{
            if commonSignaturesIndex != nil {
                if commonSignaturesIndex > Configuration.commonConfigurations.count - 1 {
                    self.commonSignaturesIndex = 0
                }
                let config = Configuration.commonConfigurations[commonSignaturesIndex!]
                beatsControl.numberOfShards = config.beats
            }
        }
    }

    private var running: Bool = false {
        willSet(newValue){
            if newValue == true {
                timer.start()
                bpmControl.running = true
                UIApplication.sharedApplication().idleTimerDisabled = true

            } else {
                beatsControl.activeShard = nil
                timer.stop()
                bpmControl.running = false
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
        bpmControl.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "intervalWasFired:",
                                                         name: "interval",
                                                         object: nil)
        //This gets fired whenever changes occur in QuickSettings
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSettingsFromUserDefaults", name:
        NSUserDefaultsDidChangeNotification, object: nil)
        defaults = NSUserDefaults.standardUserDefaults()

        let beats = defaults.integerForKey("beats")
        beatsControl.numberOfShards = beats
        let accents = UInt(defaults.integerForKey("accents"))
        beatsControl.activated = accents
        beatsControl.delegate = self

        addKerning(settingsButton)
        addKerning(quickSettingsButton)
        addKerning(sessionButton)


        let bpm = defaults.integerForKey("bpm")
        bpmControl.bpm = bpm
        timer.bpm = bpm

        setupSessionEventHandlers()

    }

    override func viewDidAppear(animated: Bool) {
        beatsControl.frame = view.frame
        let halfWidth = CGRectGetMidX(UIScreen.mainScreen().bounds)
        let halfHeight = CGRectGetMidY(UIScreen.mainScreen().bounds)
        let radius = hypot(halfWidth, halfHeight)

        beatsControl.radius = radius

        if defaults.boolForKey("firstLaunch") {
            // Get view controllers and build the walkthrough
            let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
            let walkthrough = stb.instantiateViewControllerWithIdentifier("master") as! BWWalkthroughViewController
            let page_one = stb.instantiateViewControllerWithIdentifier("basics") as! UIViewController

            // Attach the pages to the master
            //walkthrough.delegate = self
            walkthrough.addViewController(page_one)
            walkthrough.view!.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            walkthrough.modalPresentationStyle = .OverCurrentContext
            walkthrough.modalTransitionStyle = .CrossDissolve

            presentViewController(walkthrough, animated: true, completion: nil)
            defaults.setBool(false, forKey: "firstLaunch")
        }
        
    }

    //@discussion listens to the timer emitting beatParts.
    func intervalWasFired(notification: NSNotification) {
        let part = notification.userInfo!["beatPart"] as! Int
        let beatPart = UInt16(part)
        if (beatPart & BeatPartMeanings.OnTheBeat.rawValue) > 0 {
            beatsControl.activateNext()
            if defaults.boolForKey("beat") {
                SoundPlayer.playBeat()
            }
            if defaults.boolForKey("screenFlash") {
                beatsControl?.flashBackground()
            }
            if defaults.boolForKey("ledFlashOnBeat") {
                LED.flash()
            }
            if beatsControl.activeIsAccent() {
                if defaults.boolForKey("ledFlashOnAccent") {
                    LED.flash()
                }
                SoundPlayer.playAccent()
                beatsControl.flashBackground()
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
        if beats != beatsControl.numberOfShards {
            beatsControl.numberOfShards = beats
            if ConnectionManager.inSession {
                let change: [String: MPCSerializable] = ["beats": MPCInt(value: beats)]
                ConnectionManager.sendEvent(.ChangeBeats, object: change)
            }
        }
        let digital = defaults.boolForKey("digitalVoice")
        if  digital != SoundPlayer.getDigitalVoice() {
            SoundPlayer.digitalVoice(digital)
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
        bpmControl.bpm = Int(Double(secondsInMinute) / (delta))
    }

    @IBAction func cycleTimeSignature(sender: AnyObject) {
        let delta = timeSignatureTracker.benchmark()
        if delta > 2 {
            commonSignaturesIndex = 0
        } else {
            commonSignaturesIndex!++
        }

    }
    @IBAction func didSwipeLeft(){
        defaults.setInteger(beatsControl!.numberOfShards - 1, forKey: "beats")
    }
    @IBAction func didSwipeRight(){
        defaults.setInteger(beatsControl!.numberOfShards + 1, forKey: "beats")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            running = false

            let viewControllers = segue.destinationViewController.viewControllers as Array
            let settingsViewController = viewControllers[0] as! SettingsViewController
            settingsViewController.delegate = self
            settingsViewController.screenFlash = defaults.boolForKey("screenFlash")
            settingsViewController.ledFlashOnBeat = defaults.boolForKey("ledFlashOnBeat")
            settingsViewController.ledFlashOnAccent = defaults.boolForKey("ledFlashOnAccent")
            settingsViewController.digitalVoice = defaults.boolForKey("digitalVoice")
        }
    }

    // MARK: Overlays

    @IBAction func presentSessionController() {
        let window = UIApplication.sharedApplication().keyWindow!
        sessionController = SessionViewController()
        bpmControl.tintAdjustmentMode = .Dimmed
        sessionController!.delegate = self
        window.addSubview(sessionController!.view)
        sessionController!.animateIn()
    }

    @IBAction func presentQuickSettings() {
        let window = UIApplication.sharedApplication().keyWindow!
        bpmControl.tintAdjustmentMode = .Dimmed
        quickSettings = QuickSettingsViewController(nibName:"QuickSettingsPanel", bundle: NSBundle.mainBundle())

        quickSettings!.delegate = self
        window.addSubview(quickSettings!.view)
        quickSettings!.beatControl.on = defaults.boolForKey("beat")
        quickSettings!.divisionControl.on = defaults.boolForKey("division")
        quickSettings!.subdivisionControl.on = defaults.boolForKey("subdivision")
        quickSettings!.tripletControl.on = defaults.boolForKey("triplet")
        let beats = defaults.integerForKey("beats")
        quickSettings!.beatsControlLabel.text = "\(beats)"
        quickSettings!.beatsControl.value = Double(beats)
        quickSettings!.animateIn()
    }


    func sessionViewControllerDidFinish(event: SessionEvent?){
        bpmControl.tintAdjustmentMode = .Normal
        sessionController!.animateOut()
        sessionController = nil
        if event == nil {
            ConnectionManager.stop()
        } else {
            switch event! {
                case .Initiated:
                    let initialConfig: [String: MPCSerializable] = ["bpm": MPCInt(value: self.bpmControl!.bpm), "beats": MPCInt(value: beatsControl!.numberOfShards)]
                    ConnectionManager.sendEvent(.StartSession, object: initialConfig)
                case .Left:
                    ConnectionManager.stop()
                default:
                    let test = true
            }
        }

    }

    @IBAction func unwindViewController(sender: UIStoryboardSegue){
        let source = sender.sourceViewController as! UIViewController
        dismissViewControllerAnimated(true, completion: nil)
    }

    func quickSettingsViewControllerDidFinish() {
        bpmControl.tintAdjustmentMode = .Normal
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
    
    private func addKerning(button: UIButton){
        let string = button.titleLabel?.attributedText.mutableCopy() as! NSMutableAttributedString
        string.addAttribute(NSKernAttributeName, value: 1.0, range: NSMakeRange(0, string.length))
        button.setAttributedTitle(string, forState: .Normal)
        let insetAmount: CGFloat = 4.0;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
    
    }

    // MARK: Sessions

    private func setupSessionEventHandlers(){
        ConnectionManager.onEvent(.StartSession, run: {
            peerID, object in
            let dict = object as! [String: NSData]

            let bpm = MPCInt(mpcSerialized: dict["bpm"]!).value
            let beats = MPCInt(mpcSerialized: dict["beats"]!).value
            self.timer.bpm = bpm
            self.bpmControl!.bpm = bpm
            self.beatsControl!.numberOfShards = beats
            if self.sessionController != nil {
                //This may cause a bug if the other person starts a session very soon after the first
                //person does. The SessionController will be already removed from the view or being animated.
                self.sessionController!.delegate?.sessionViewControllerDidFinish(.Joined)
            }
            ConnectionManager.heartBeat()
        })
        ConnectionManager.onEvent(.ChangeBeats, run: {
            peerID, object in
            let dict = object as! [String: NSData]

            let beats = MPCInt(mpcSerialized: dict["beats"]!).value
            self.beatsControl!.numberOfShards = beats
        })
        ConnectionManager.onEvent(.ChangeBPM, run: {
            peerID, object in
            let dict = object as! [String: NSData]

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
        ConnectionManager.onEvent(.Heartbeat, run: {
            peerID, object in
            let packet:[String: MPCSerializable] = ["HeartbeatResponse": MPCInt(value: Int(mach_absolute_time()))]
            ConnectionManager.sendEvent(.HeartbeatResponse, object: packet)

        })
        ConnectionManager.onEvent(.HeartbeatResponse, run: {
            peerID, object in
            let dict = object as! [String: NSData]
            let senderTime: Int = MPCInt(mpcSerialized: dict["HeartbeatResponse"]!).value
            ConnectionManager.latency[peerID] = Int(ConnectionManager.lastHeartbeatTime) - senderTime
            println(ConnectionManager.lastHeartbeatTime - senderTime)
        })
    }
}