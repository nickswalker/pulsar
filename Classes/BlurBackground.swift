import Foundation
import UIKit

class BlurBackground: UIView {

    override func awakeFromNib() {
        let old = frame
        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurBackground.frame = old
        addSubview(blurBackground)
        sendSubview(toBack: blurBackground)
    }

}
