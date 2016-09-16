import Foundation
import MultipeerConnectivity
import Mixpanel

protocol SettingsDelegate {
    func settingChangedForKey(_ key: String, value: AnyObject)
    func shouldDisplayHelpOverlay()
}

class SettingsViewController: UITableViewController {
    var delegate: SettingsDelegate?
    var screenFlash: Bool = false
    var ledFlashOnBeat: Bool = false
    var ledFlashOnAccent: Bool = false
    var digitalVoice: Bool = false
    @IBOutlet weak var screenFlashControl: UISwitch!
    @IBOutlet weak var ledFlashOnBeatControl : UISwitch!
    @IBOutlet weak var ledFlashOnAccentControl : UISwitch!
    @IBOutlet weak var digitalVoiceControl: UISwitch!

    override func viewDidLoad() {
        screenFlashControl.isOn = screenFlash
        ledFlashOnAccentControl.isOn = ledFlashOnAccent
        ledFlashOnBeatControl.isOn = ledFlashOnBeat
        digitalVoiceControl.isOn = digitalVoice
        
    }

    @IBAction func settingChanged(_ sender: UISwitch) {
        let key: String
        switch sender {
            case self.screenFlashControl:
                key = "screenFlash"
            case self.ledFlashOnBeatControl:
                key = "ledFlashOnBeat"
            case self.ledFlashOnAccentControl:
                key = "ledFlashOnAccent"
            case self.digitalVoiceControl:
                key = "digitalVoice"
            default:
                abort()
        }

        let mixpanel = Mixpanel.mainInstance()

        mixpanel.track(event: "Setting changed", properties:["Setting": key])
        delegate?.settingChangedForKey(key, value: sender.isOn as AnyObject)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1   {
            UIApplication.shared.openURL(URL(string: "https://nickwalker.us/pulsar")!)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if (indexPath as NSIndexPath).section == 0   {
            cell.selectionStyle = .none
        }
        return cell
    }
    // Hide the LED related rows if we're on a device that doesn't have one
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !LED.hasLED() && ((indexPath as NSIndexPath).row == 1 || (indexPath as NSIndexPath).row == 2) {
            return 0
        }
        else
        {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAbout" {
            let destination = segue.destination.view as! UIWebView
            let file = URL(fileURLWithPath: Bundle.main.path(forResource: "about", ofType: "html")!)
            destination.loadRequest(URLRequest(url: file))

        }
    }
    @IBAction func didPressHelpButton(_ sender: UIButton){
        delegate?.shouldDisplayHelpOverlay()
    }
}
