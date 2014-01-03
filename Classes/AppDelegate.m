#import "AppDelegate.h"
#import "Metronome.h"
#import "GAI.h"

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *appDefaults = @{ @"screenFlash": @YES, @"ledFlash": @NO, @"vibrate": @NO, @"master": @NO, @"bpm": @60, @"accents":@[@1], @"timeSignature":@[@4,@4], @"division":@YES, @"subdivision":@NO };
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

	//Metronome *controller = (Metronome *)self.window.rootViewController;
	//controller.managedObjectContext = self.managedObjectContext;
	
	// Optional: automatically send uncaught exceptions to Google Analytics.
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	
	// Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
	[GAI sharedInstance].dispatchInterval = 20;
	
	// Optional: set Logger to VERBOSE for debug information.
	// [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
	
	// Initialize tracker.
	 [[GAI sharedInstance] trackerWithTrackingId:@"UA-30066313-2"];
	
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"syncDefaults" object:nil];
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
#pragma mark - State Restore

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
	return YES;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
