//
//  UpdateBeaconViewController.h
//  nRFBeacons
//
//  Created by Kamran Saleem Soomro on 05/02/15.
//  Copyright (c) 2015 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateScanTableViewController.h"

@interface UpdateBeaconViewController : UIViewController <scanPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

- (IBAction)uuidPressed:(UIButton *)sender;
- (IBAction)ledSwitchChanged:(UISwitch *)sender;
- (IBAction)connectButtonPressed:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UILabel *verticalText;
@property (weak, nonatomic) IBOutlet UIButton *uuidButton;
@property (weak, nonatomic) IBOutlet UITextField *majorText;
@property (weak, nonatomic) IBOutlet UITextField *minorText;
@property (weak, nonatomic) IBOutlet UITextField *rssiText;
@property (weak, nonatomic) IBOutlet UITextField *manufacturingIdText;
@property (weak, nonatomic) IBOutlet UITextField *advertisingIntervalText;

@property (weak, nonatomic) IBOutlet UISwitch *ledEnabledSwitch;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end
