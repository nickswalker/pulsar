#import <UIKit/UIKit.h>

@class Settings;

@protocol SettingsViewControllerDelegate
@required
- (void)settingsViewControllerDidFinish:(Settings *)controller;
@end

@interface Settings : UITableViewController <UIBarPositioningDelegate>

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property IBOutlet UISwitch* vibrateControl;
@property IBOutlet UISwitch* screenFlashControl;
@property IBOutlet UISwitch* ledFlashControl;
@property IBOutlet UISwitch* masterControl;
@property IBOutlet UISwitch* divisionControl;
@property IBOutlet UISwitch* subdivisionControl;

-(IBAction)done:(id)sender;
-(IBAction)toggleScreenFlash:(UISwitch*)screenFlashSwitch;
-(IBAction)toggleLedFlash:(UISwitch*)ledSwitch;
-(IBAction)toggleVibrate:(UISwitch*)vibrateSwitch;
-(IBAction)toggleMaster:(UISwitch*)masterSwitch;

@end
