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

    var overlayController: QuickSettingsViewController?
    var player = SoundPlayer()
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var commonTimeSignatures: [AnyObject]!
    var defaults = NSUserDefaults.standardUserDefaults()
    var commonSignaturesIndex = 0
    var opacityAnimation: () -> () = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        opacityAnimation  = {
            self.backgroundButton!.backgroundColor = UIColor.clearColor()
        }
        backgroundButton!.backgroundColor = UIColor.clearColor()
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
        let part = notification.userInfo!["beatPart"] as Int
        let beatPart:UInt16 = UInt16(part)
        if (beatPart & BeatPartMeanings.OnTheBeat.rawValue) > 0 {
            beatsControl!.activateNext()
            if defaults.boolForKey("beat") {
                player.playBeat()
            }
            if defaults.boolForKey("screenFlash") {
                flashScreen()
            }
            if defaults.boolForKey("ledFlash") {
                LED.flash()
            }
            if beatsControl!.activeIsAccent() {
                player.playAccent()
                flashScreen()
            }
        } else if (beatPart & BeatPartMeanings.Division.rawValue) > 0 {
            if defaults.boolForKey("division") {
                player.playDivision()
            }
        } else if (beatPart & BeatPartMeanings.SubDivision.rawValue) > 0 {
            if defaults.boolForKey("subdivision") {
                player.playSubdivision()
            }
        } else if (beatPart & BeatPartMeanings.Triplet.rawValue) > 0 {
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
        backgroundButton!.backgroundColor = UIColor.whiteColor()
        UIView.animateWithDuration(0.1, animations: opacityAnimation)
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
            // FIXME: Need a way to turn it off that's not so invasive

            var viewControllers = segue.destinationViewController.viewControllers as Array
            var settingsViewController: SettingsViewController = viewControllers[0] as SettingsViewController
            settingsViewController.delegate = self
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