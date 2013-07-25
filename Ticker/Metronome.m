//
//  MainViewController.m
//  Ticker
//
//  Created by Nick Walker on 7/18/13.
//  Copyright (c) 2013 Nick Walker. All rights reserved.
//

#import "Metronome.h"
#import "Timer.h"
#import "SoundPlayer.h"
#import <CoreBluetooth/CoreBluetooth.h>
//@interface MainViewController ()
//@end
@implementation Metronome

Timer* timeKeeper;
SoundPlayer* player;
NSUserDefaults* defaults;
static NSString * const kServiceUUID = @"312700E2-E798-4D5C-8DCF-49908332DF9F";
static NSString * const kCharacteristicUUID = @"FFA28CDE-6525-4489-801C-1C060CAC9767";

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Setup flashing view
	self.whiteScreen = [[UIView alloc] initWithFrame:self.view.frame];
    self.whiteScreen.layer.opacity = 0.0f;
    self.whiteScreen.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self.view addSubview:self.whiteScreen];
	
	//Setup stored defaults
	defaults = [NSUserDefaults standardUserDefaults];
	
	timeKeeper = [[Timer alloc] initWithDelegate: self];
	
	//Match the display to the stepper value
	[self changeBPM:self.stepper];
	
	//Start bluetooth
	//self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

	//Setup player
	player =  [[SoundPlayer alloc] init];
	;
	// Start running if the metronome is on
	[self toggleTimer:(UISwitch *)self.timerSwitch];
}

#pragma mark - UI
-(IBAction)changeBPM:(UIStepper*)sender	{
	self.bpmLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	[timeKeeper changeBpm:sender.value];
}
-(IBAction)toggleTimer:(UISwitch*)toggle{
	if (toggle.on) [timeKeeper startTimer], timeKeeper.on=true;
	else [timeKeeper stopTimer], timeKeeper.on=false;
}
- (IBAction)changeSignature:(UISegmentedControl *)signature	{
	[timeKeeper changeSignature:(int)signature.selectedSegmentIndex+1 and:(int)4];
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
	self.stepper.value = self.stepper.value - -1*translation.y/10;
	[self changeBPM:self.stepper];
	[recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}
-(void)beat
{
	if (timeKeeper.count == 1) {
		[player playTickSound];
	}else {
		[player playTockSound];
	}
	if ([defaults boolForKey:@"flashing"]) [self flashScreen];
}
-(void)flashScreen {
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    NSArray *animationValues = @[ @0.8f, @0.0f ];
    NSArray *animationTimes = @[ @0.3f, @1.0f ];
    id timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    NSArray *animationTimingFunctions = @[ timingFunction, timingFunction ];
    [opacityAnimation setValues:animationValues];
    [opacityAnimation setKeyTimes:animationTimes];
    [opacityAnimation setTimingFunctions:animationTimingFunctions];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.duration = 0.4;
	
    [self.whiteScreen.layer addAnimation:opacityAnimation forKey:@"animation"];
}

#pragma mark - BlueTooth

//- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
//    switch (peripheral.state) {
//        case CBPeripheralManagerStatePoweredOn:
//            [self setupService];
//            break;
//        default:
//            NSLog(@"Peripheral Manager did change state");
//            break;
//    }
//}
//- (void)setupService {
//    // Creates the characteristic UUID
//    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
//	
//    // Creates the characteristic
//    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
//	
//    // Creates the service UUID
//    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
//	
//    // Creates the service and adds the characteristic to it
//    self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
//	
//    // Sets the characteristics for this service
//    [self.customService setCharacteristics:@[self.customCharacteristic]];
//	
//    // Publishes the service
//    [self.peripheralManager addService:self.customService];
//}
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
//    if (error == nil) {
//        // Starts advertising the service
//        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : @"ICServer", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
//    }
//}
#pragma mark - settings View Controller

- (void)settingsViewControllerDidFinish:(Settings *)controller
{
	if (self.timerSwitch.isOn) [timeKeeper startTimer];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.settingsPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.settingsPopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[timeKeeper stopTimer];
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.settingsPopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.settingsPopoverController) {
        [self.settingsPopoverController dismissPopoverAnimated:YES];
        self.settingsPopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
