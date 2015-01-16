import Foundation
import MultipeerConnectivity

protocol SettingsDelegate {
    func settingChangedForKey(key: String, value: AnyObject)
    func settingsViewControllerDidFinish()
}

class SettingsViewController: UITableViewController, UITableViewDataSource {
    var delegate: SettingsDelegate?
    @IBOutlet var screenFlashControl: UISwitch?
    @IBOutlet var ledFlashControl : UISwitch?
    @IBOutlet var digitalVoiceControl: UISwitch?

    @IBAction func done(sender: AnyObject) {
        delegate?.settingsViewControllerDidFinish()
    }

    @IBAction func settingChanged(sender: UISwitch) {
        let key: String = {
            switch sender {
                case self.screenFlashControl!:
                    return "screenFlash"
                case self.ledFlashControl!:
                    return "ledFlash"
                case self.digitalVoiceControl!:
                    return "digitalVoice"
                default:
                    abort()
            }
        }()

        delegate?.settingChangedForKey(key, value: sender.on)
    }
}
