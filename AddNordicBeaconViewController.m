/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AddNordicBeaconViewController.h"
#import "UpdateScanTableViewController.h"
#import "BeaconsDatabase.h"

@interface AddNordicBeaconViewController ()

@property (strong, nonatomic) CBPeripheral *beaconPeripheral;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic)CBUUID *beaconServiceUUID;
@property (strong, nonatomic)CBUUID *majorMinorCharacteristicUUID;
@property (strong, nonatomic)CBUUID *rssiCharacteristicUUID;
@property (strong, nonatomic)CBUUID *beaconUUIDCharacteristicUUID;
@property (strong, nonatomic)CBUUID *manufacturingIdCharacteristicUUID;
@property (strong, nonatomic)CBUUID *advertisingIntervalCharacteristicUUID;
@property (strong, nonatomic)CBUUID *ledCharacteristicUUID;

@property (strong, nonatomic)CBCharacteristic *majorMinorCharacteristic;
@property (strong, nonatomic)CBCharacteristic *beaconUUIDCharacteristic;
@property (strong, nonatomic)CBCharacteristic *rssiCharacteristic;
@property (strong, nonatomic)CBCharacteristic *manufacturingIdCharacteristic;
@property (strong, nonatomic)CBCharacteristic *advertisingIntervalCharacteristic;
@property (strong, nonatomic)CBCharacteristic *ledCharacteristic;
@property (strong, nonatomic) BeaconsDatabase *database;

@end

@implementation AddNordicBeaconViewController

const int APPLE_ID = 76;
const int NORDIC_SEMICONDUCTOR_ID = 89;
bool isManufacturingIdCharacteristicFound = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Rotate the vertical label
    self.verticalLabel.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(-145.0f, 0.0f), (float)(-M_PI / 2));
    
    self.beaconPeripheral = nil;
    self.centralManager = nil;
    
    self.beaconServiceUUID = [CBUUID UUIDWithString:@"955A1523-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.majorMinorCharacteristicUUID = [CBUUID UUIDWithString:@"955A1526-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.rssiCharacteristicUUID = [CBUUID UUIDWithString:@"955A1525-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.beaconUUIDCharacteristicUUID = [CBUUID UUIDWithString:@"955A1524-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.manufacturingIdCharacteristicUUID = [CBUUID UUIDWithString:@"955A1527-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.advertisingIntervalCharacteristicUUID = [CBUUID UUIDWithString:@"955A1528-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.ledCharacteristicUUID = [CBUUID UUIDWithString:@"955A1529-0FE2-F5AA-A094-84B8D4F3E8AD"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showAlert:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

-(BOOL) isSupportedUUID:(NSString *)uuid
{
    for (int index = 0; index < [[Utility getBeaconsUUIDS] count]; index++) {
        if ([[[[Utility getBeaconsUUIDS] objectAtIndex:index]UUIDString]
             caseInsensitiveCompare:uuid] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Beacon Decoders

-(int8_t)decodeRSSI:(NSData *)data
{
    NSLog(@"decodeRSSI");
    const uint8_t *value = [data bytes];
    return (int8_t)value[0];
}

-(uint16_t)decodeMajor:(NSData *)data
{
    NSLog(@"decodeMajor");
    const uint8_t *value = [data bytes];
    return CFSwapInt16BigToHost(*(uint16_t *)(&value[0]));
}

-(uint16_t)decodeMinor:(NSData *)data
{
    NSLog(@"decodeMinor");
    const uint8_t *value = [data bytes];
    return CFSwapInt16BigToHost(*(uint16_t *)(&value[2]));
}

-(NSString *)decodeUUID:(NSData *)data
{
    NSLog(@"decodeUUID");
    const uint8_t * value = [data bytes];
    NSMutableString *uuidString = [[NSMutableString alloc]init];
    for(int index=0; index<16; index++)
    {
        [uuidString appendFormat:@"%02X",value[index]];
        if (index == 3 || index == 5 || index == 7 || index == 9) {
            [uuidString appendString:@"-"];
        }
    }
    return [uuidString copy];
}

-(uint16_t)decodeManufacturingId:(NSData *)data
{
    NSLog(@"decodeManufacturingId %@",data);
    const uint8_t *value = [data bytes];
    return CFSwapInt16LittleToHost(*(uint16_t *)(&value[0]));
}

-(uint16_t)decodeAdvertisingInterval:(NSData *)data
{
    NSLog(@"decodeAdvertisingId %@",data);
    const uint8_t *value = [data bytes];
    return CFSwapInt16LittleToHost(*(uint16_t *)(&value[0]));
}

-(BOOL)decodeLed:(NSData *)data
{
    NSLog(@"decodeRSSI");
    const uint8_t *value = [data bytes];
    if ((int8_t)value[0] == 1) {
        return YES;
    }
    else {
        return NO;
    }
    
}



#pragma mark - Scanner delegate

-(void) selectedPeripheral:(CBPeripheral *)peripheral centralManager:(CBCentralManager *)centralManager
{
    NSLog(@"selected peripheral: %@",peripheral.name);
    self.beaconPeripheral = peripheral;
    self.centralManager = centralManager;
    self.centralManager.delegate = self;
    self.beaconPeripheral.delegate = self;
    [self.centralManager connectPeripheral:self.beaconPeripheral options:nil];
}

#pragma mark - CBCentralManager delagates

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"didUpdateState");
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral %@",peripheral.name);
    [self.connectButton setTitle:@"DISCONNECT" forState:UIControlStateNormal];
    [self.beaconPeripheral discoverServices:[NSArray arrayWithObject:self.beaconServiceUUID]];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral %@",peripheral.name);
    [self.connectButton setTitle:@"CONNECT" forState:UIControlStateNormal];
    self.beaconPeripheral = nil;
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral %@",peripheral.name);
}

#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices %@",peripheral.name);
    for(CBService *service in peripheral.services)
    {
        if ([service.UUID isEqual:self.beaconServiceUUID]) {
            NSLog(@"Beacon Config service found");
            [self.beaconPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristics");
    if ([service.UUID isEqual:self.beaconServiceUUID]) {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:self.beaconUUIDCharacteristicUUID]) {
                NSLog(@"UUID characteristic found: %@",characteristic.UUID);
                self.beaconUUIDCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.majorMinorCharacteristicUUID]) {
                NSLog(@"Major Minor characteristic found: %@",characteristic.UUID);
                self.majorMinorCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.rssiCharacteristicUUID]) {
                NSLog(@"RSSI characteristic found: %@",characteristic.UUID);
                self.rssiCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.manufacturingIdCharacteristicUUID]) {
                NSLog(@"Manufacturing Id characteristic found: %@",characteristic.UUID);
                self.manufacturingIdCharacteristic = characteristic;
                isManufacturingIdCharacteristicFound = YES;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.advertisingIntervalCharacteristicUUID]) {
                NSLog(@"Advertising Interval characteristic found: %@",characteristic.UUID);
                self.advertisingIntervalCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:self.ledCharacteristicUUID]) {
                NSLog(@"LED characteristic found: %@",characteristic.UUID);
                self.ledCharacteristic = characteristic;
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
            }

        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic");
    if ([characteristic.UUID isEqual:self.beaconUUIDCharacteristicUUID]) {
        NSLog(@"UUID characteristic Value: %@",[self decodeUUID:characteristic.value]);
        self.uuidLabel.text = [self decodeUUID:characteristic.value];
    }
    else if ([characteristic.UUID isEqual:self.majorMinorCharacteristicUUID]) {
        NSString *major = [NSString stringWithFormat:@"%hu",[self decodeMajor:characteristic.value]];
        NSString *minor = [NSString stringWithFormat:@"%hu",[self decodeMinor:characteristic.value]];
        NSLog(@"Major characteristic Value: %@",major);
        NSLog(@"Minor characteristic Value: %@",minor);
        self.majorText.text = major;
        self.minorText.text = minor;
        
    }
    else if ([characteristic.UUID isEqual:self.rssiCharacteristicUUID]) {
        NSString *rssi = [NSString stringWithFormat:@"%hhd",[self decodeRSSI:characteristic.value]];
        NSLog(@"RSSI characteristic Value: %@",rssi);
        self.rssiText.text = rssi;
    }
    else if ([characteristic.UUID isEqual:self.manufacturingIdCharacteristicUUID]) {
        //NSString *manufacturingId = [NSString stringWithFormat:@"%hu",[self decodeManufacturingId:characteristic.value]];
        int manufId = [self decodeManufacturingId:characteristic.value];
        NSLog(@"Manufacturing Id characteristic Value: %d",manufId);
        //self.manufacturingIdLabel.text = manufacturingId;
        [self showManufacturingID:manufId];
    }
    else if ([characteristic.UUID isEqual:self.advertisingIntervalCharacteristicUUID]) {
        NSString *advertisingInterval = [NSString stringWithFormat:@"%hu",[self decodeAdvertisingInterval:characteristic.value]];
        NSLog(@"Advertising Interval characteristic Value: %@",advertisingInterval);
        self.advertisingIntervalLabel.text = advertisingInterval;
    }
    else if ([characteristic.UUID isEqual:self.ledCharacteristicUUID]) {
        if ([self decodeLed:characteristic.value]) {
            NSLog(@"Led is enbled");
            self.ledStatusLabel.text = @"ON";
        }
        else {
            NSLog(@"Led is disabled");
            self.ledStatusLabel.text = @"OFF";
        }
    }

}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error in writing characteristic %@",characteristic.UUID);
        [self showAlert:[error localizedDescription] title:@"Error"];
    }
    else {
        NSLog(@"success characteristic written %@",characteristic.UUID);
    }
}

-(void)showManufacturingID:(int)manufacturingId
{
    NSLog(@"showManufacturingId %d",manufacturingId);
    if (manufacturingId == APPLE_ID) {
        self.manufacturingIdLabel.text = @"Apple";
    }
    else if (manufacturingId == NORDIC_SEMICONDUCTOR_ID) {
        self.manufacturingIdLabel.text = @"Nordic";
    }
    else {
        self.manufacturingIdLabel.text = [NSString stringWithFormat:@"%d",manufacturingId];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"scan"]) {
        NSLog(@"prepareForSegue UpdateServiceController");
        UINavigationController *navController = segue.destinationViewController;
        UpdateScanTableViewController *scanVC = (UpdateScanTableViewController *)navController.topViewController;
        scanVC.scanDelegate = self;
        [self clearView];
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"scan"] && self.beaconPeripheral == nil) {
        return YES;
    }
    return NO;
}

-(void)clearView
{
    self.uuidLabel.text = @"-";
    self.majorText.text = @"-";
    self.minorText.text = @"-";
    self.rssiText.text = @"-";
    self.manufacturingIdLabel.text = @"n/a";
    self.advertisingIntervalLabel.text = @"n/a";
    self.ledStatusLabel.text = @"n/a";
    isManufacturingIdCharacteristicFound = NO;
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)connectButtonPressed:(UIButton *)sender {
    NSLog(@"connect button pressed");
    if (self.beaconPeripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.beaconPeripheral];
    }
}
- (IBAction)donePressed:(UIBarButtonItem *)sender {
    NSLog(@"Add button pressed on Navigation bar");
    if (self.beaconPeripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.beaconPeripheral];
    }
    int major = [self.majorText.text intValue];
    int minor = [self.minorText.text intValue];
    NSString *uuid = self.uuidLabel.text;
    if ([uuid isEqualToString:@"-"]) {
        [self showAlert:@"Can't add new Beacon, UUID is empty!\n Please connect to Nordic Beacon" title:@"Error"];
        return;
    }
    if (![self isSupportedUUID:uuid]) {
        [self showAlert:[NSString stringWithFormat:@"Beacon UUID <%@> is not supported, Please select one of the provided Beacon UUIDs",uuid] title:@"Error"];
        return;
    }
    if (major > 65535 || minor > 65535) {
        [self showAlert:@"Beacon Major,Minor must be less than 65536" title:@"Error"];
        return;
    }
    if (isManufacturingIdCharacteristicFound && ![self.manufacturingIdLabel.text isEqualToString:@"Apple"]) {
        NSLog(@"Manufacturing Id is not set to Apple");
        [self showAlert:@"Beacons's Manufacturing Id must be set to Apple Id (76) to work with IOS" title:@"Error"];
        return;
    }
    
    BeaconData *newBeacon = [[BeaconData alloc]init];
    newBeacon.name = @"nRF Beacon";
    newBeacon.uuid = uuid;
    newBeacon.major = [NSNumber numberWithInt:major];
    newBeacon.minor = [NSNumber numberWithInt:minor];
    newBeacon.event = [[Utility getBeaconsEvents] firstObject];
    newBeacon.action = [[Utility getBeaconsActions] firstObject];
    newBeacon.enable = [NSNumber numberWithBool:YES];
    
    self.database = [[BeaconsDatabase alloc]init];
    BeaconAddStatus addStatus = [self.database addNewBeacon:newBeacon];
    if (addStatus == DUPLICATE_IN_ADD) {
        [self showAlert:@"OOPS! Another beacon with same UUID+Major+Minor combination already exist." title:@"Beacon Duplication"];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}
@end
