import UIKit
import Foundation

let myTintColor = UIColor(red: 0.0941, green: 0.741, blue: 0.27, alpha: 1)
//UIColor(red: 0.655, green: 0.203, blue: 0.807, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {

        let defaultPreferences = ["screenFlash": true,
                                  "ledFlash": false,
                                  "vibrate": false,
                                  "master": false,
                                  "bpm": 60,
                                  "accents": [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                                  "timeSignature": [4, 4],
                                  "beat": true,
                                  "division": true,
                                  "subdivision": false,
                                  "triplet": false
        ]

        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!], forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 15)!], forState: .Normal)
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultPreferences)


        // Optional: automatically send uncaught exceptions to Google Analytics.
        //GAI.sharedInstance().trackUncaughtExceptions = true

        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        //GAI.sharedInstance().dispatchInterval = 20

        // Optional: set Logger to VERBOSE for debug information.
        //GAI.sharedInstance().logger().setLogLevel();

        // Initialize tracker.
        //GAI.sharedInstance().trackerWithTrackingId("UA-30066313-2")

        window!.tintColor = myTintColor
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

