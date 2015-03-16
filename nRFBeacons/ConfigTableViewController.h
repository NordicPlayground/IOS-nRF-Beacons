//
//  ConfigTableViewController.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BeaconData.h"
#import "Beacons.h"

@interface ConfigTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UITextField *majorText;
@property (weak, nonatomic) IBOutlet UITextField *minorText;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;



@property(strong, nonatomic) Beacons *selectedBeacon;
@property(strong, nonatomic) BeaconData *existingBeacon;
@property(nonatomic) BOOL isAddView;

- (IBAction)enableSwitchChanged:(UISwitch *)sender;

@end
