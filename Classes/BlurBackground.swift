import Foundation
import UIKit

class BlurBackground: UIView {

    override func awakeFromNib() {
        let old = frame
        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurBackground.frame = old
        addSubview(blurBackground)
        sendSubviewToBack(blurBackground)
    }

}