import Foundation
import MultipeerConnectivity

protocol SettingsDelegate {
    func settingsViewControllerDidFinish()
}

class SettingsViewController: UITableViewController, UITableViewDataSource {
    var delegate: SettingsDelegate?
    var defaults: NSUserDefaults
    @IBOutlet var screenFlashControl: UISwitch?
    @IBOutlet var ledFlashControl : UISwitch?
    @IBOutlet var digitalVoiceControl: UISwitch?


    override init(style: UITableViewStyle) {
        defaults = NSUserDefaults.standardUserDefaults()
        super.init(style: style)

    }
    required init(coder aDecoder: NSCoder) {
        defaults = NSUserDefaults.standardUserDefaults()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        // Make switches reflect defaults
        self.defaults = NSUserDefaults.standardUserDefaults()
        screenFlashControl!.on = defaults.boolForKey("screenFlash")
        ledFlashControl!.on = defaults.boolForKey("ledFlash")
        digitalVoiceControl!.on = defaults.boolForKey("digitalVoice")

    }

    @IBAction func done(sender: AnyObject) {
        defaults.synchronize()
        delegate?.settingsViewControllerDidFinish()
    }

    @IBAction func settingChanged(sender: UISwitch) {
        defaults = NSUserDefaults.standardUserDefaults()
        var key: String?
        var value: Bool
        switch sender {
            case screenFlashControl!:
                key = "screenFlash"
            case ledFlashControl!:
                key = "ledFlash"
            case digitalVoiceControl!:
                key = "digitalVoice"
            default:
                key = nil
        }

        if key != nil {
            defaults.setBool(sender.on, forKey: key!)
        }
    }
}