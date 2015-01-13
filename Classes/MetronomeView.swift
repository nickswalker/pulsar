import Foundation
import UIKit

class MetronomeView: UIView {
    override func tintColorDidChange() {
        super.tintColorDidChange()
        for subview in subviews {
            let subview = subview as UIView
            subview.tintColor = UIApplication.sharedApplication().delegate!.window!!.tintColor
            if subview is UIButton {
                let button = subview as UIButton
                button.setTitleColor(tintColor, forState: .Normal)
            }
            else {
                subview.tintColor = tintColor
                subview.tintColorDidChange()
            }
        }
    }
}