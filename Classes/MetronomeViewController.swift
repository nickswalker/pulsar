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

    var quickSettingsOverlayController: QuickSettingsViewController?
    var led = LED()
    var player = SoundPlayer()
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var commonTimeSignatures = NSArray()
    var defaults = NSUserDefaults.standardUserDefaults()
    var positionInCommonTimeSignatures = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        var path = NSBundle.mainBundle().pathForResource("standardConfigurations", ofType: "plist")
        //commonTimeSignatures = NSArray(contentsOfFile: path!)
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

    }

    override func viewDidAppear(animated: Bool) {
        beatsControl!.numberOfShards = beatsControl!.numberOfShards
    }

    //@discussion listens to the timer emitting beatParts.
    func intervalWasFired(notification: NSNotification) {

        //var denomination = notification.userInfo["beatDenomination"]
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
        timer.bpm = sender.value;
    }

    func switchToggled(sender: UISwitch) {
        toggleRunningState(sender.on)
    }

    func beatValueChanged(sender: UISegmentedControl) {

    }

    func updateSettingsFromUserDefaults() {
        defaults.synchronize()
        let newTimeSignature = defaults.objectForKey("timeSignature") as NSArray
        let beats = newTimeSignature[0] as Int
        if beats != beatsControl!.numberOfShards {
            beatsControl!.numberOfShards = beats
        }

        defaults = NSUserDefaults.standardUserDefaults()
    }
    // FIXME: This makes more sense as a computed property
    func toggleRunningState(state: Bool) {
        if state == true {
            timer.start()
            controls?.running = true
            UIApplication.sharedApplication().idleTimerDisabled = true
        } else {
            beatsControl!.activeShard = nil
            timer.stop()
            controls?.running = false
            UIApplication.sharedApplication().idleTimerDisabled = false
        }
    }

    func flashScreen() {
        backgroundButton!.layer.opacity = 0.02
        backgroundButton!.backgroundColor = UIColor.whiteColor()
        var opacityAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0.0

        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = true
        opacityAnimation.duration = 0.15
        backgroundButton!.layer.addAnimation(opacityAnimation, forKey: "animation")
    }

    //MARK: Gesture Controls

    let maxTimeBetweenTaps = 20.0

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
        var delta = timeSignatureTracker.benchmark()
        if (delta > 2) {
            positionInCommonTimeSignatures = 0
        }
        if (positionInCommonTimeSignatures > 6) {
            positionInCommonTimeSignatures = 0
        }
        //controls!.beatValue = NoteValue.fromRaw( 1/(commonTimeSignatures[positionInCommonTimeSignatures][1] as Int) )
        //beatsControl!.shards = commonTimeSignatures.objectAtIndex(positionInCommonTimeSignatures)
        positionInCommonTimeSignatures++
    }

    // MARK: Overlay Controls
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showSettings") {
            toggleRunningState(false)
            // FIXME: Need a way to turn it off that's not so invasive

            var viewControllers = segue.destinationViewController.viewControllers as Array
            var settingsViewController: SettingsViewController = viewControllers[0] as SettingsViewController
            settingsViewController.delegate = self
        }
    }

    @IBAction func presentQuickSettings() {
        let window = UIApplication.sharedApplication().keyWindow!

        quickSettingsOverlayController = QuickSettingsViewController()
        controls!.tintAdjustmentMode = .Dimmed
        quickSettingsOverlayController!.delegate = self
        quickSettingsOverlayController!.view.frame = self.view.frame
        window.addSubview(quickSettingsOverlayController!.view)
        quickSettingsOverlayController!.animateIn()
    }

    func settingsViewControllerDidFinish(controller: SettingsViewController) {
        player = SoundPlayer() //In case the voice changed, we'll reload the sounds
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func quickSettingsViewControllerDidFinish() {
        controls!.tintAdjustmentMode = .Normal
        quickSettingsOverlayController = nil;
    }

    // MARK: Appearance
    override func preferredStatusBarStyle() -> (UIStatusBarStyle) {
        return .LightContent
    }

}