import Foundation
import MultipeerConnectivity
import Mixpanel

protocol SettingsDelegate {
    func settingChangedForKey(key: String, value: AnyObject)
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
        screenFlashControl.on = screenFlash
        ledFlashOnAccentControl.on = ledFlashOnBeat
        ledFlashOnBeatControl.on = ledFlashOnAccent
        digitalVoiceControl.on = digitalVoice
        
    }

    @IBAction func settingChanged(sender: UISwitch) {
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

        let mixpanel = Mixpanel.sharedInstance()

        mixpanel.track("Setting changed", properties:["Setting": key])
        delegate?.settingChangedForKey(key, value: sender.on)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1   {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://nickwalker.us/pulsar")!)
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
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !LED.hasLED() && (indexPath.row == 1 || indexPath.row == 2) {
            return 0
        }
        else
        {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAbout" {
            let destination = segue.destinationViewController.view as! UIWebView
            let file = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("about", ofType: "html")!)
            destination.loadRequest(NSURLRequest(URL: file))

        }
    }
}
