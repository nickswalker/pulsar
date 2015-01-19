import Foundation
import MultipeerConnectivity

protocol SettingsDelegate {
    func settingChangedForKey(key: String, value: AnyObject)
    func settingsViewControllerDidFinish()
}

class SettingsViewController: UITableViewController, UITableViewDataSource {
    var delegate: SettingsDelegate?
    var screenFlash: Bool = false
    var ledFlash: Bool = false
    var digitalVoice: Bool = false
    @IBOutlet var screenFlashControl: UISwitch?
    @IBOutlet var ledFlashControl : UISwitch?
    @IBOutlet var digitalVoiceControl: UISwitch?

    override func viewDidLoad() {
        screenFlashControl!.on = screenFlash
        ledFlashControl!.on = ledFlash
        digitalVoiceControl!.on = digitalVoice
    }

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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1   {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://pulsar.nickwalker.us")!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if indexPath.section == 0   {
            cell.selectionStyle = .None
        }
        return cell
    }
}
