import UIKit
import Foundation
import Mixpanel

let myTintColor = UIColor(red: 0.0941, green: 0.741, blue: 0.27, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let mixpanel = Mixpanel.initialize(token: Config.mixPanelToken)
        mixpanel.track(event: "Launched")
        SoundPlayer.setup()
        UIApplication.shared.statusBarStyle = .lightContent

        let defaultPreferences = ["screenFlash": true,
                                  "ledFlashOnAccent": false,
            "ledFlashOnBeat": false,
                                  "vibrate": false,
                                  "bpm": 60,
                                  "accents": 0b1,
                                  "beats": 4,
                                  PulseType.Beat.rawValue: true,
                                  PulseType.Division.rawValue: true,
                                  PulseType.Subdivision.rawValue: false,
                                  PulseType.Triplet.rawValue: false,
                                  "firstLaunch": true
        ] as [String : Any]

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 17)!], for: UIControlState())
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 15)!], for: UIControlState())
        UserDefaults.standard.register(defaults: defaultPreferences)

        window!.tintColor = myTintColor

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

