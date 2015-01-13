import Foundation
import UIKit
import QuartzCore
import MetronomeControl

typealias TimeSignature = MetronomeControl.TimeSignature
typealias NoteValue = MetronomeControl.NoteValue

let accentOnFirstBeat = [1]

class MetronomeViewController: UIViewController, SettingsViewControllerDelegate,
        MetronomeControlDelegate, QuickSettingsViewControllerDelegate {

    @IBOutlet var backgroundButton: UIButton?
    @IBOutlet var controls: MetronomeControl?
    @IBOutlet var beatsControl: ShardControl?
    @IBOutlet var quickSettingsButton: UIButton?
    @IBOutlet var settingsButton: UIButton?
    @IBOutlet var sessionButton: UIButton?

    var overlayController: QuickSettingsViewController?
    var led = LED()
    var player = SoundPlayer()
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var commonTimeSignatures: [AnyObject]!
    var defaults = NSUserDefaults.standardUserDefaults()
    var commonSignaturesIndex = 0

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

        let newTimeSignature = defaults.objectForKey("timeSignature") as NSArray
        let beats = newTimeSignature[0] as Int
        beatsControl!.numberOfShards = beats

        let bpm = defaults.objectForKey("bpm") as Int
        controls!.bpm = bpm

    }

    override func viewDidAppear(animated: Bool) {
        beatsControl!.numberOfShards = beatsControl!.numberOfShards
    }

    //@discussion listens to the timer emitting beatParts.
    func intervalWasFired(notification: NSNotification) {
        // FIXME: This is going to need to be faster. Too much branching
        let part: Int = Int(notification.userInfo?["beatPart"] as NSNumber)
        if find(onTheBeat, part) != nil {
            beatsControl!.activateNext()
            if defaults.boolForKey("beat") {
                player.playBeat()
            }
            if defaults.boolForKey("screenFlash") {
                flashScreen()
            }
            if beatsControl!.activeIsAccent() {
                player.playAccent()
                flashScreen()
            }
        } else if find(division, part) != nil {
            if defaults.boolForKey("division") {
                player.playDivision()
            }
        } else if find(subDivision, part) != nil {
            if defaults.boolForKey("subdivision") {
                player.playSubdivision()
            }
        } else if find(triplet, part) != nil {
            if defaults.boolForKey("triplet") {
                player.playTriplet()
            }
        }

    }

    //MARK: MetronomeControlDelegate

    func bpmChanged(sender: SlideStepper) {
        timer.bpm = sender.value
        defaults.setObject(sender.value, forKey: "bpm")
        defaults.synchronize()
    }

    func switchToggled(sender: UISwitch) {
        toggleRunningState(sender.on)
    }

    func updateSettingsFromUserDefaults() {
        //The defaults were changed externally: pull in the changes
        defaults.synchronize()
        let newTimeSignature = defaults.objectForKey("timeSignature") as NSArray
        let beats = newTimeSignature[0] as Int
        if beats != beatsControl!.numberOfShards {
            beatsControl!.numberOfShards = beats
        }
    }

    // FIXME: This makes more sense as a computed property
    func toggleRunningState(state: Bool) {
        if state == true {
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

    func flashScreen() {
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

    // MARK: Overlay Controls
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            toggleRunningState(false)

            let viewControllers = segue.destinationViewController.viewControllers as Array
            let settingsViewController = viewControllers[0] as SettingsViewController
            settingsViewController.delegate = self
        }
        else if segue.identifier == "showSession" {
            let sessionViewController = segue.destinationViewController as SessionViewController
            sessionViewController.modalPresentationStyle = .OverCurrentContext
        }
    }

    @IBAction func presentQuickSettings() {
        let window = UIApplication.sharedApplication().keyWindow!

        overlayController = QuickSettingsViewController(nibName:"QuickSettingsControlsView", bundle: NSBundle.mainBundle())
        controls!.tintAdjustmentMode = .Dimmed
        overlayController!.delegate = self
        window.addSubview(overlayController!.view)
        overlayController!.animateIn()
    }

    func settingsViewControllerDidFinish() {
        player = SoundPlayer() //In case the voice changed, we'll reload the sounds
        dismissViewControllerAnimated(true, completion: nil)
    }

    func quickSettingsViewControllerDidFinish() {
        controls!.tintAdjustmentMode = .Normal
        overlayController = nil
    }

    // MARK: Appearance
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return .LightContent
    }

}