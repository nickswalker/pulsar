import Foundation
import UIKit

class MetronomeView: UIView {
    override func tintColorDidChange() {
        super.tintColorDidChange()
        for subview in subviews {
            let subview = subview 
            subview.tintColor = UIApplication.shared.delegate!.window!!.tintColor
            if subview is UIButton {
                let button = subview as! UIButton
                button.setTitleColor(tintColor, for: UIControlState())
                let string = button.attributedTitle(for: UIControlState())!.mutableCopy() as! NSMutableAttributedString
                string.addAttribute(NSAttributedStringKey.foregroundColor, value: tintColor, range: NSRange(location: 0, length: string.length))
                button.setAttributedTitle(string, for: UIControlState())
            }
            else {
                subview.tintColor = tintColor
                subview.tintColorDidChange()
            }
        }
    }
}
