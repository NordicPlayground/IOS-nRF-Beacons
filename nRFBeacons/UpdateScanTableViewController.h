//
//  UpdateScanTableViewController.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 13/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol scanPeripheral <NSObject>
-(void) selectedPeripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager;
@end

@interface UpdateScanTableViewController : UITableViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender;
@property (retain)id <scanPeripheral> scanDelegate;

@end
