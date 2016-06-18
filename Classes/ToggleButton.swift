import Foundation
import UIKit

@IBDesignable class ToggleButton: UIButton {
    var activeTouch = false
    var animated = true
    @IBInspectable var on: Bool = false {
        willSet(newValue) {
            if newValue == true {
                let update = {
                    () -> () in
                    self.backgroundColor = self.tintColor
                    self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }

                if self.animated {
                    UIView.animateWithDuration(0.2, animations: update)
                } else {
                    update()
                }
            } else {
                let update = {
                    () -> () in
                    self.backgroundColor = UIColor.clearColor()
                    self.setTitleColor(self.tintColor, forState: .Normal)
                }
                if self.animated {
                    UIView.animateWithDuration(0.2, animations: update)
                } else {
                    update()
                }
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        backgroundColor = UIColor.clearColor()
        layer.borderColor = tintColor!.CGColor
        layer.borderWidth = 1
        layer.cornerRadius = 4.0
        layer.actions = ["backgroundColor": NSNull(), "titleColor": NSNull()]
        titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 15.0)

        addTarget(self, action: #selector(ToggleButton.touchDown), forControlEvents: .TouchDown)
        addTarget(self, action: #selector(ToggleButton.cancel), forControlEvents: [.TouchUpOutside, .TouchCancel])
        tintAdjustmentMode = .Normal
    }

    func touchDown() {
        on = !on
        sendActionsForControlEvents(.ValueChanged)
    }

    func cancel() {
        on = !on
        sendActionsForControlEvents(.ValueChanged)
    }

    override func tintColorDidChange() {
        let isInactive = self.tintAdjustmentMode == .Dimmed
        if isInactive {
            // modify subviews to look disabled
        } else {
            layer.borderColor = tintColor!.CGColor
            on = Bool(on)

        }
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 88, height: 44)
    }
}