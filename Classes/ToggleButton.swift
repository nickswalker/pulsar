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
                    self.setTitleColor(UIColor.white, for: UIControlState())
                }

                if self.animated {
                    UIView.animate(withDuration: 0.2, animations: update)
                } else {
                    update()
                }
            } else {
                let update = {
                    () -> () in
                    self.backgroundColor = UIColor.clear
                    self.setTitleColor(self.tintColor, for: UIControlState())
                }
                if self.animated {
                    UIView.animate(withDuration: 0.2, animations: update)
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
        backgroundColor = UIColor.clear
        layer.borderColor = tintColor!.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4.0
        layer.actions = ["backgroundColor": NSNull(), "titleColor": NSNull()]
        titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 15.0)

        addTarget(self, action: #selector(ToggleButton.touchDown), for: .touchDown)
        addTarget(self, action: #selector(ToggleButton.cancel), for: [.touchUpOutside, .touchCancel])
        tintAdjustmentMode = .normal
    }

    @objc func touchDown() {
        on = !on
        sendActions(for: .valueChanged)
    }

    @objc func cancel() {
        on = !on
        sendActions(for: .valueChanged)
    }

    override func tintColorDidChange() {
        let isInactive = self.tintAdjustmentMode == .dimmed
        if isInactive {
            // modify subviews to look disabled
        } else {
            layer.borderColor = tintColor!.cgColor
            on = Bool(on)

        }
    }

    override var intrinsicContentSize : CGSize {
        return CGSize(width: 88, height: 44)
    }
}
