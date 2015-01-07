import Foundation
import UIKit

class ControlsView: UIView {
    @IBOutlet var blurBackground: UIVisualEffectView?
    @IBOutlet var beatControl: ToggleButton?
    @IBOutlet var divisionControl: ToggleButton?
    @IBOutlet var subdivisionControl: ToggleButton?
    @IBOutlet var tripletControl: ToggleButton?
    @IBOutlet var beatsControl: UIStepper?
    @IBOutlet var beatsControlLabel: UILabel?

    var defaults = NSUserDefaults.standardUserDefaults()

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
        let old = blurBackground!.frame
        blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurBackground!.frame = old
        addSubview(blurBackground!)
        sendSubviewToBack(blurBackground!)
        beatControl!.on = defaults.boolForKey("beat")
        divisionControl!.on = defaults.boolForKey("division")
        subdivisionControl!.on = defaults.boolForKey("subdivision")
        tripletControl!.on = defaults.boolForKey("triplet")
        let timeSignature = defaults.objectForKey("timeSignature") as NSArray
        let currentBeats = timeSignature[0] as NSNumber
        beatsControlLabel?.text = Int(currentBeats).description
        beatsControl?.value = Double(currentBeats)
    }

    @IBAction func settingChanged(sender: ToggleButton) {
        var key: String?
        var value: Bool
        if sender == beatControl {
            key = "beat"
        } else if sender == divisionControl {
            key = "division"
        } else if sender == subdivisionControl {
            key = "subdivision"
        } else if sender == tripletControl {
            key = "triplet"
        }

        if key != nil {
            defaults.setBool(sender.on, forKey: key!)
        }
        defaults.synchronize()
    }

    @IBAction func beatsChanged(sender: UIStepper) {
        beatsControlLabel?.text = Int(sender.value).description
        let currentTimeSignature = defaults.objectForKey("timeSignature") as NSArray
        defaults.setObject([Int(sender.value), currentTimeSignature[1]], forKey: "timeSignature")
    }
}