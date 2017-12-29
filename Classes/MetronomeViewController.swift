import Foundation
import UIKit
import QuartzCore
import LabeledSlideStepper

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let accentOnFirstBeat = [1]

class MetronomeViewController: UIViewController, SettingsDelegate,
        LabeledSlideStepperDelegate, QuickSettingsDelegate, ShardControlDelegate, BWWalkthroughViewControllerDelegate {

    @IBOutlet weak var bpmControl: LabeledSlideStepper!
    @IBOutlet weak var beatsControl: ShardControl!
    @IBOutlet weak var quickSettingsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var sessionButton: UIButton!

    var quickSettings: QuickSettingsViewController?
    var bpmTracker = DeltaTracker()
    var timer = Timer()
    var timeSignatureTracker = DeltaTracker()
    var defaults = UserDefaults.standard
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

    fileprivate var running: Bool = false {
        willSet(newValue){
            if newValue == true {
                timer.start()
                bpmControl.running = true
                UIApplication.shared.isIdleTimerDisabled = true

            } else {
                beatsControl.activeShard = nil
                timer.stop()
                bpmControl.running = false
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        opacityAnimation  = {
            self.view.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        }

        bpmControl.delegate = self
        beatsControl.delegate = self



        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(MetronomeViewController.intervalWasFired(_:)),
                                                         name: NSNotification.Name(rawValue: "interval"),
                                                         object: nil)
        //This gets fired whenever changes occur in QuickSettings
        NotificationCenter.default.addObserver(self, selector: #selector(MetronomeViewController.updateSettingsFromUserDefaults), name:
        UserDefaults.didChangeNotification, object: nil)
        defaults = UserDefaults.standard

        updateSettingsFromUserDefaults()

        addKerning(settingsButton)
        addKerning(quickSettingsButton)
        //addKerning(sessionButton)

    }

    override func viewDidAppear(_ animated: Bool) {
        beatsControl.frame = view.frame
        let halfWidth = UIScreen.main.bounds.midX
        let halfHeight = UIScreen.main.bounds.midY
        let radius = hypot(halfWidth, halfHeight)

        beatsControl.radius = radius

        // For debugging. Force first launch behavior
        //defaults.setBool(true, forKey: "firstLaunch")
        if defaults.bool(forKey: "firstLaunch") {
            presentHelpOverlay()
            defaults.set(false, forKey: "firstLaunch")
        }
        
    }

    //@discussion listens to the timer emitting beatParts.
    @objc func intervalWasFired(_ notification: Notification) {
        let part = (notification as NSNotification).userInfo!["beatPart"] as! Int
        let beatPart = UInt(part)
        if (beatPart & BeatPartMeanings.onTheBeat.rawValue) != 0 {
            beatsControl.activateNext()
            if defaults.bool(forKey: PulseType.Beat.rawValue) {
                SoundPlayer.schedule(.Beat)
            }
            if defaults.bool(forKey: "screenFlash") {
                beatsControl?.flashBackground()
            }
            if defaults.bool(forKey: "ledFlashOnBeat") {
                LED.flash()
            }
            if beatsControl.activeIsAccent() {
                if defaults.bool(forKey: "ledFlashOnAccent") {
                    LED.flash()
                }
                SoundPlayer.schedule(.Accent)
                beatsControl.flashBackground()
            }
        } else if (beatPart & BeatPartMeanings.division.rawValue) != 0 {
            if defaults.bool(forKey: PulseType.Division.rawValue) {
                SoundPlayer.schedule(.Division)
            }
        } else if (beatPart & BeatPartMeanings.subDivision.rawValue) != 0 {
            if defaults.bool(forKey: PulseType.Subdivision.rawValue) {
                SoundPlayer.schedule(.Subdivision)
            }
        } else if (beatPart & BeatPartMeanings.triplet.rawValue) != 0 {
            if defaults.bool(forKey: PulseType.Triplet.rawValue) {
                SoundPlayer.schedule(.Triplet)
            }
        }

    }

    //MARK: MetronomeControlDelegate

    func bpmChanged(_ sender: SlideStepper) {
        timer.bpm = sender.value
        defaults.set(sender.value, forKey: "bpm")
        defaults.synchronize()
    }

    func switchToggled(_ sender: UISwitch) {
        running = sender.isOn
    }

    @objc func updateSettingsFromUserDefaults() {
        //The defaults were changed externally: pull in the changes
        defaults.synchronize()

        let bpm = defaults.integer(forKey: "bpm")
        bpmControl.bpm = bpm
        timer.bpm = bpm

        let beats = defaults.integer(forKey: "beats")
        if beats != beatsControl.numberOfShards {
            beatsControl.numberOfShards = beats
        }

        let accents = UInt(defaults.integer(forKey: "accents"))
        beatsControl.activated = accents

        let digital = defaults.bool(forKey: "digitalVoice")
        SoundPlayer.digitalVoice = digital

    }

    //MARK: Gestures

    fileprivate let maxTimeBetweenTaps = 20.0

    @IBAction func matchBpm(_ sender: AnyObject) {
        let delta = bpmTracker.benchmark()
        if delta == 0 {
            return
        } else if ((Double(secondsInMinute) / delta) < maxTimeBetweenTaps) {
            return
        }
        let value = Int(Double(secondsInMinute) / (delta))
        defaults.set(value, forKey: "bpm")
    }

    @IBAction func cycleTimeSignature(_ sender: AnyObject) {
        let delta = timeSignatureTracker.benchmark()
        if delta > 2 {
            commonSignaturesIndex = 0
        } else {
            commonSignaturesIndex! += 1
        }

    }
    @IBAction func didSwipeLeft(){
        defaults.set(beatsControl!.numberOfShards - 1, forKey: "beats")
    }
    @IBAction func didSwipeRight(){
        defaults.set(beatsControl!.numberOfShards + 1, forKey: "beats")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings" {
            running = false

            let viewController = segue.destination as! UINavigationController
            let settingsViewController = viewController.viewControllers[0] as! SettingsViewController
            settingsViewController.delegate = self
            settingsViewController.screenFlash = defaults.bool(forKey: "screenFlash")
            settingsViewController.ledFlashOnBeat = defaults.bool(forKey: "ledFlashOnBeat")
            settingsViewController.ledFlashOnAccent = defaults.bool(forKey: "ledFlashOnAccent")
            settingsViewController.digitalVoice = defaults.bool(forKey: "digitalVoice")
        }
    }

    // MARK: Overlays

    @IBAction func presentSessionController() {
        let window = UIApplication.shared.keyWindow!
        bpmControl.tintAdjustmentMode = .dimmed
    }

    @IBAction func presentQuickSettings() {
        let window = UIApplication.shared.keyWindow!
        bpmControl.tintAdjustmentMode = .dimmed
        quickSettings = QuickSettingsViewController(nibName:"QuickSettingsPanel", bundle: Bundle.main)

        quickSettings!.delegate = self
        window.addSubview(quickSettings!.view)
        quickSettings!.beatControl.on = defaults.bool(forKey: PulseType.Beat.rawValue)
        quickSettings!.divisionControl.on = defaults.bool(forKey: PulseType.Division.rawValue)
        quickSettings!.subdivisionControl.on = defaults.bool(forKey: PulseType.Subdivision.rawValue)
        quickSettings!.tripletControl.on = defaults.bool(forKey: PulseType.Triplet.rawValue)
        let beats = defaults.integer(forKey: "beats")
        quickSettings!.beatsControlLabel.text = "\(beats)"
        quickSettings!.beatsControl.value = Double(beats)
        quickSettings!.animateIn()
    }

    func walkthroughCloseButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func unwindViewController(_ sender: UIStoryboardSegue){
        dismiss(animated: true, completion: nil)
    }

    func quickSettingsViewControllerDidFinish() {
        bpmControl.tintAdjustmentMode = .normal
        quickSettings = nil
    }

    func settingChangedForKey(_ key: String, value: AnyObject) {
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }
    func shouldDisplayHelpOverlay() {
        dismiss(animated: true, completion: nil)
        presentHelpOverlay()
    }

    func presentHelpOverlay(){
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "master") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "basics")

        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.view!.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        walkthrough.modalPresentationStyle = .overCurrentContext
        walkthrough.modalTransitionStyle = .crossDissolve

        present(walkthrough, animated: true, completion: nil)
    }

    func activatedShardsChanged() {
        defaults.set(Int(beatsControl!.activated), forKey: "accents")
    }

    // MARK: Appearance
    override var preferredStatusBarStyle : (UIStatusBarStyle) {
        return .lightContent
    }
    
    fileprivate func addKerning(_ button: UIButton){
        let string = button.titleLabel?.attributedText!.mutableCopy() as! NSMutableAttributedString
        string.addAttribute(NSAttributedStringKey.kern, value: 1.0, range: NSMakeRange(0, string.length))
        button.setAttributedTitle(string, for: UIControlState())
        let insetAmount: CGFloat = 4.0;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
    
    }

}
