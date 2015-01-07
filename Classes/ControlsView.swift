import Foundation
import UIKit

class ControlsView: UIView {

    override init() {
        super.init()
        commonInit()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {

    }

    override func awakeFromNib() {
        let old = frame
        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurBackground.frame = old
        addSubview(blurBackground)
        sendSubviewToBack(blurBackground)
    }

}