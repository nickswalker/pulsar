import Foundation
import UIKit

protocol BackgroundViewDelegate {
    func viewWasTapped()
}

protocol QuickSettingsViewControllerDelegate {
    func quickSettingsViewControllerDidFinish()
}

public class QuickSettingsViewController: UIViewController, BackgroundViewDelegate {

    class HideBackgroundView: UIView {
        var delegate: BackgroundViewDelegate?
        override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
            if let target = delegate {
                target.viewWasTapped()
            }
        }
    }

    var overlayView = HideBackgroundView()
    var controlArea = NSBundle.mainBundle().loadNibNamed("QuickSettingsControlsView", owner: nil, options: nil)[0] as ControlsView
    var delegate: QuickSettingsViewControllerDelegate?

    func animateIn() {
        let controlAreaHeight: CGFloat = controlArea.frame.height
        self.view.userInteractionEnabled = true

        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        overlayView.frame = self.view.frame
        overlayView.alpha = 0
        overlayView.delegate = self

        let deviceHeight: CGFloat = view.frame.height
        let deviceWidth: CGFloat = view.frame.width
        let scale = UIScreen.mainScreen().scale

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        controlArea.frame = offscreenFrame

        view.addSubview(overlayView)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.overlayView.alpha = 1
        }, completion: nil)

        view.addSubview(controlArea)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.controlArea.frame = onscreenFrame
        }, completion: nil)

    }

    func animateOut() {
        let controlAreaHeight: CGFloat = controlArea.frame.height
        let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.height
        let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.width

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.overlayView.alpha = 0
        }, completion: { succeeded in self.overlayView.removeFromSuperview() })


        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.controlArea.frame = offscreenFrame
        }, completion: {
            succeeeded in self.controlArea.removeFromSuperview()
            self.view.userInteractionEnabled = false
        })
        if let target = delegate {
            target.quickSettingsViewControllerDidFinish()
        }

    }

    func viewWasTapped() {
        animateOut()
    }
}
