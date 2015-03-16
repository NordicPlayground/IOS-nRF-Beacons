//
//  AddNordicBeaconViewController.h
//  nRFBeacons
//
//  Created by Kamran Saleem Soomro on 03/02/15.
//  Copyright (c) 2015 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateScanTableViewController.h"

@interface AddNordicBeaconViewController : UIViewController <scanPeripheral, CBCentralManagerDelegate, CBPeripheralDelegate>

- (IBAction)cancelPressed:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UILabel *verticalLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorText;
@property (weak, nonatomic) IBOutlet UILabel *minorText;
@property (weak, nonatomic) IBOutlet UILabel *rssiText;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@property (weak, nonatomic) IBOutlet UILabel *manufacturingIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *advertisingIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *ledStatusLabel;

- (IBAction)connectButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
- (IBAction)donePressed:(UIBarButtonItem *)sender;

@end
