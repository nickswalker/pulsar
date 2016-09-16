import Foundation
import UIKit

protocol BackgroundViewDelegate {
    func viewWasTapped()
}

protocol QuickSettingsDelegate {
    func settingChangedForKey(_ key: String, value: AnyObject)
    func quickSettingsViewControllerDidFinish()
}

open class QuickSettingsViewController: UIViewController, BackgroundViewDelegate {

    @IBOutlet weak var blurBackground: UIVisualEffectView!
    @IBOutlet weak var beatControl: ToggleButton!
    @IBOutlet weak var divisionControl: ToggleButton!
    @IBOutlet weak var subdivisionControl: ToggleButton!
    @IBOutlet weak var tripletControl: ToggleButton!
    @IBOutlet weak var beatsControl: UIStepper!
    @IBOutlet weak var beatsControlLabel: UILabel!

    fileprivate class HideBackgroundView: UIView {
        var delegate: BackgroundViewDelegate?
        fileprivate override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            delegate?.viewWasTapped()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {


    }
    fileprivate var overlayView = HideBackgroundView()
    var delegate: QuickSettingsDelegate?

    func animateIn() {
        let controlAreaHeight: CGFloat = view.frame.height
        view.isUserInteractionEnabled = true

        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        overlayView.frame = UIScreen.main.bounds
        overlayView.alpha = 0
        overlayView.delegate = self

        let deviceHeight: CGFloat = UIScreen.main.bounds.height
        let deviceWidth: CGFloat = UIScreen.main.bounds.width

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        view.frame = offscreenFrame

        //Insert right beneath the controls panel
        let index = view.superview!.subviews.count - 2
        view.superview!.insertSubview(overlayView, aboveSubview: view.superview!.subviews[index] )
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.overlayView.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.view.frame = onscreenFrame
        }, completion: nil)

    }

    func animateOut() {
        let controlAreaHeight: CGFloat = view.frame.height
        let deviceHeight: CGFloat = UIScreen.main.bounds.height
        let deviceWidth: CGFloat = UIScreen.main.bounds.width

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.overlayView.alpha = 0
        }, completion: { succeeded in self.overlayView.removeFromSuperview() })


        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.view.frame = offscreenFrame
        }, completion: {
            succeeeded in self.view.removeFromSuperview()
            self.view.isUserInteractionEnabled = false
        })
        if let target = delegate {
            target.quickSettingsViewControllerDidFinish()
        }

    }

    @IBAction func settingChanged(_ sender: ToggleButton) {
        let key: String = {
            switch sender {
                case self.beatControl:
                    return PulseType.Beat.rawValue
                case self.divisionControl :
                    return PulseType.Division.rawValue
                case self.subdivisionControl :
                    return PulseType.Subdivision.rawValue
                case self.tripletControl :
                    return PulseType.Triplet.rawValue
                default:
                    abort()
            }
        }()

        delegate?.settingChangedForKey(key, value: sender.on as AnyObject)
    }

    @IBAction func beatsChanged(_ sender: UIStepper) {
        beatsControlLabel?.text = Int(sender.value).description
        delegate?.settingChangedForKey("beats", value: Int(sender.value) as AnyObject)
    }

    func viewWasTapped() {
        animateOut()
    }
}
