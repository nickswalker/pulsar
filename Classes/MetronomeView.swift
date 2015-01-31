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
                let string = button.attributedTitleForState(.Normal)! as NSMutableAttributedString
                string.addAttribute(NSForegroundColorAttributeName, value: tintColor, range: NSRange(location: 0, length: string.length))
                button.setAttributedTitle(string, forState: .Normal)
            }
            else {
                subview.tintColor = tintColor
                subview.tintColorDidChange()
            }
        }
    }
}