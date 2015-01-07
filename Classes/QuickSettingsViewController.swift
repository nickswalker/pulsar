import Foundation
import UIKit

protocol BackgroundViewDelegate {
    func viewWasTapped()
}

protocol QuickSettingsViewControllerDelegate {
    func quickSettingsViewControllerDidFinish()
}

public class QuickSettingsViewController: UIViewController, BackgroundViewDelegate {

    @IBOutlet var blurBackground: UIVisualEffectView?
    @IBOutlet var beatControl: ToggleButton?
    @IBOutlet var divisionControl: ToggleButton?
    @IBOutlet var subdivisionControl: ToggleButton?
    @IBOutlet var tripletControl: ToggleButton?
    @IBOutlet var beatsControl: UIStepper?
    @IBOutlet var beatsControlLabel: UILabel?

    var defaults = NSUserDefaults.standardUserDefaults()

    private class HideBackgroundView: UIView {
        var delegate: BackgroundViewDelegate?
        override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
            if let target = delegate {
                target.viewWasTapped()
            }
        }
    }

    public override func viewWillAppear(animated: Bool) {
        beatControl!.on = defaults.boolForKey("beat")
        divisionControl!.on = defaults.boolForKey("division")
        subdivisionControl!.on = defaults.boolForKey("subdivision")
        tripletControl!.on = defaults.boolForKey("triplet")
        let timeSignature = defaults.objectForKey("timeSignature") as NSArray
        let currentBeats = timeSignature[0] as NSNumber
        beatsControlLabel!.text = Int(currentBeats).description
        beatsControl!.value = Double(currentBeats)

    }
    private var overlayView = HideBackgroundView()
    var delegate: QuickSettingsViewControllerDelegate?

    func animateIn() {
        let controlAreaHeight: CGFloat = view.frame.height
        view.userInteractionEnabled = true

        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        overlayView.frame = UIScreen.mainScreen().bounds
        overlayView.alpha = 0
        overlayView.delegate = self

        let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.height
        let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.width
        let scale = UIScreen.mainScreen().scale

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        view.frame = offscreenFrame

        //Insert right beneath the controls panel
        let index = view.superview!.subviews.count - 2
        view.superview!.insertSubview(overlayView, aboveSubview: view.superview!.subviews[index] as UIView)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.overlayView.alpha = 1
        }, completion: nil)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.frame = onscreenFrame
        }, completion: nil)

    }

    func animateOut() {
        let controlAreaHeight: CGFloat = view.frame.height
        let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.height
        let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.width

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.overlayView.alpha = 0
        }, completion: { succeeded in self.overlayView.removeFromSuperview() })


        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.frame = offscreenFrame
        }, completion: {
            succeeeded in self.view.removeFromSuperview()
            self.view.userInteractionEnabled = false
        })
        if let target = delegate {
            target.quickSettingsViewControllerDidFinish()
        }

    }

    @IBAction func settingChanged(sender: ToggleButton) {
        let key: String = {
            switch sender {
                case self.beatControl!:
                    return "beat"
                case self.divisionControl! :
                    return "division"
                case self.subdivisionControl! :
                    return "subdivision"
                case self.tripletControl! :
                    return "triplet"
                default:
                    abort()
            }
        }()

        defaults.setBool(sender.on, forKey: key)
        defaults.synchronize()
    }

    @IBAction func beatsChanged(sender: UIStepper) {
        beatsControlLabel?.text = Int(sender.value).description
        let currentTimeSignature = defaults.objectForKey("timeSignature") as NSArray
        defaults.setObject([Int(sender.value), currentTimeSignature[1]], forKey: "timeSignature")
    }

    func viewWasTapped() {
        animateOut()
    }
}
