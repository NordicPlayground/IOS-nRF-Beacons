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

#import "UpdateBeaconViewController.h"
#import "UpdateScanTableViewController.h"
#import "UUIDPopoverTableViewController.h"
#import "ManufacturingIdPopoverTableViewController.h"

@interface UpdateBeaconViewController ()

@property UIBarButtonItem *doneButton;

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



@end

@implementation UpdateBeaconViewController

const int MAX_UNSIGNED_SHORT_VALUE = 65535;
const int MAX_RSSI_VALUE = -128;
bool isAdvancedPropertiesExist = NO;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Rotate the vertical label
    self.verticalText.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(-145.0f, 0.0f), (float)(-M_PI / 2));
    
    self.beaconPeripheral = nil;
    self.centralManager = nil;
    
    self.beaconServiceUUID = [CBUUID UUIDWithString:@"955A1523-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.majorMinorCharacteristicUUID = [CBUUID UUIDWithString:@"955A1526-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.rssiCharacteristicUUID = [CBUUID UUIDWithString:@"955A1525-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.beaconUUIDCharacteristicUUID = [CBUUID UUIDWithString:@"955A1524-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.manufacturingIdCharacteristicUUID = [CBUUID UUIDWithString:@"955A1527-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.advertisingIntervalCharacteristicUUID = [CBUUID UUIDWithString:@"955A1528-0FE2-F5AA-A094-84B8D4F3E8AD"];
    self.ledCharacteristicUUID = [CBUUID UUIDWithString:@"955A1529-0FE2-F5AA-A094-84B8D4F3E8AD"];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self action:@selector(doneEditing:)];
    
    [self clearBasicProperties];
    [self clearAdvancedProperties];
    [self disableBasicProperties];
    [self disableAdvancedProperties];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSLog(@"UpdateBeaconViewController viewDidAppear");
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    NSLog(@"UpdateBeaconViewController viewDidDisappear");
    if (self.beaconPeripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.beaconPeripheral];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text editing

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    if (textField == self.manufacturingIdText) {
        [self showPopoverOnManufacturingId:textField];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");
    if (textField == self.majorText) {
        [self updateMajorMinor];
    }
    else if (textField == self.minorText) {
        [self updateMajorMinor];
    }
    else if (textField == self.rssiText) {
        [self updateRSSI];
    }
    /*else if (textField == self.manufacturingIdText) {
        [self updateManufacturingID];
    }*/
    else if (textField == self.advertisingIntervalText) {
        [self updateAdvertisingInterval];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"scan"]) {
        NSLog(@"prepareForSegue UpdateServiceController");
        UINavigationController *navController = segue.destinationViewController;
        UpdateScanTableViewController *scanVC = (UpdateScanTableViewController *)navController.topViewController;
        scanVC.scanDelegate = self;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"scan"] && self.beaconPeripheral == nil) {
        return YES;
    }
    return NO;
}

- (IBAction)uuidPressed:(UIButton *)sender {
    [self showPopoverOnUUID:sender];
}

- (IBAction)ledSwitchChanged:(UISwitch *)sender {
    NSLog(@"LedSwitchChanged");
    [self updateLedStatus];
}

#pragma mark - Views Visibility State

-(void)clearBasicProperties
{
    [self.uuidButton setTitle:@"-" forState:UIControlStateNormal];
    self.majorText.text = @"";
    self.minorText.text = @"";
    self.rssiText.text = @"";
}

-(void)clearAdvancedProperties
{
    self.manufacturingIdText.text = @"";
    self.advertisingIntervalText.text = @"";
}

-(void)enableBasicProperties
{
    self.uuidButton.enabled = YES;
    self.majorText.enabled = YES;
    self.minorText.enabled = YES;
    self.rssiText.enabled = YES;
}

-(void)enableAdvancedProperties
{
    self.manufacturingIdText.enabled = YES;
    self.advertisingIntervalText.enabled = YES;
    self.ledEnabledSwitch.enabled = YES;
}

-(void)disableBasicProperties
{
    self.uuidButton.enabled = NO;
    self.majorText.enabled = NO;
    self.minorText.enabled = NO;
    self.rssiText.enabled = NO;
}

-(void)disableAdvancedProperties
{
    self.manufacturingIdText.enabled = NO;
    self.advertisingIntervalText.enabled = NO;
    self.ledEnabledSwitch.enabled = NO;
}

#pragma mark - Connect Button

- (IBAction)connectButtonPressed:(UIButton *)sender {
    NSLog(@"connect button pressed");
    if (self.beaconPeripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.beaconPeripheral];
    }
}

#pragma mark - Done Button

- (IBAction)doneEditing:(id)sender
{
    NSLog(@"doneEditing");
    [self.majorText resignFirstResponder];
    [self.minorText resignFirstResponder];
    [self.rssiText resignFirstResponder];
    [self.manufacturingIdText resignFirstResponder];
    [self.advertisingIntervalText resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - update Beacon

-(void)updateMajorMinor
{
    NSLog(@"updateMajorMinor");
    int majorText = [self.majorText.text intValue];
    int minorText = [self.minorText.text intValue];
    if (majorText > MAX_UNSIGNED_SHORT_VALUE || minorText > MAX_UNSIGNED_SHORT_VALUE) {
        [self showAlert:@"Beacon Major,Minor must be less than 65536" title:@"Error"];
        return;
    }
    uint16_t major = (uint16_t)[self.majorText.text intValue];
    uint16_t minor = (uint16_t)[self.minorText.text intValue];
    uint8_t majorMinor[4];
    majorMinor[0] = ((major >> 8) & 0xFF);
    majorMinor[1] = (major & 0xFF);
    majorMinor[2] = ((minor >> 8) & 0xFF);
    majorMinor[3] = (minor & 0xFF);
    NSData *data = [NSData dataWithBytes:majorMinor length:4];
    NSLog(@"MajorMinor Value %@",data);
    [self.beaconPeripheral writeValue:data forCharacteristic:self.majorMinorCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)updateBeaconUUID
{
    NSLog(@"updateBeaconUUID");
    uint8_t beaconUUID[16];
    NSString *uuid = self.uuidButton.titleLabel.text;
    NSLog(@"Beacon UUID is %@",uuid);
    int beaconIndex = 0;
    for (int index=0; index<16; index++) {
        if ([[uuid substringWithRange:NSMakeRange(beaconIndex, 1)] isEqualToString:@"-"]) {
            beaconIndex++;
        }
        NSString *byteString = [uuid substringWithRange:NSMakeRange(beaconIndex, 2)];
        NSScanner *pScanner = [NSScanner scannerWithString:byteString];
        unsigned int value;
        [pScanner scanHexInt:&value];
        NSLog(@"index %d UUID in String %@ UUID in Hex %02x",index,byteString,value);
        beaconUUID[index] = value;
        beaconIndex = beaconIndex + 2;
    }
    NSData *data = [NSData dataWithBytes:&beaconUUID length:16];
    NSLog(@"Beacon UUID before save %@",data);
    [self.beaconPeripheral writeValue:data forCharacteristic:self.beaconUUIDCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)updateRSSI
{
    NSLog(@"saveRSSI");
    if ([self.rssiText.text intValue] > 0) {
        self.rssiText.text = [NSString stringWithFormat:@"-%@",self.rssiText.text];
    }
    int rssiText = [self.rssiText.text intValue];
    if (rssiText < MAX_RSSI_VALUE) {
        [self showAlert:@"Beacon RSSI must be under -129" title:@"Error"];
        return;
    }
    int8_t rssi = (int8_t)[self.rssiText.text intValue];
    NSLog(@"rssi before save: %hhd",rssi);
    NSData *data = [NSData dataWithBytes:&rssi length:1];
    NSLog(@"RSSI Value %@",data);
    [self.beaconPeripheral writeValue:data forCharacteristic:self.rssiCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)updateManufacturingID
{
    NSLog(@"updateManufacturingID");
    int manufacturingIdText = [self.manufacturingIdText.text intValue];
    if (manufacturingIdText > MAX_UNSIGNED_SHORT_VALUE ) {
        [self showAlert:@"Beacon Manufacturing Id must be less than 65536" title:@"Error"];
        return;
    }

    uint16_t manId = (uint16_t)[self.manufacturingIdText.text intValue];
    uint8_t manufacturingId[2];
    manufacturingId[0] = (manId & 0xFF);
    manufacturingId[1] = ((manId >> 8) & 0xFF);
    NSData *data = [NSData dataWithBytes:manufacturingId length:2];
    NSLog(@"Manufacturing Id Value %@",data);
    [self.beaconPeripheral writeValue:data forCharacteristic:self.manufacturingIdCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)updateAdvertisingInterval
{
    NSLog(@"updateAdvertisingInterval");
    int advertisingIntervalText = [self.advertisingIntervalText.text intValue];
    if (advertisingIntervalText > MAX_UNSIGNED_SHORT_VALUE ) {
        [self showAlert:@"Beacon Advertising Interval must be less than 65536" title:@"Error"];
        return;
    }
    uint16_t advInt = (uint16_t)[self.advertisingIntervalText.text intValue];
    uint8_t advertisingInterval[2];
    advertisingInterval[0] = (advInt & 0xFF);
    advertisingInterval[1] = ((advInt >> 8) & 0xFF);
    NSData *data = [NSData dataWithBytes:advertisingInterval length:2];
    NSLog(@"Advertising Interval Value %@",data);
    [self.beaconPeripheral writeValue:data forCharacteristic:self.advertisingIntervalCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)updateLedStatus
{
    NSLog(@"updateLedStatus");
    int8_t led = (int8_t)(self.ledEnabledSwitch.on ? 1 : 0);
    NSLog(@"Led value before save: %@",self.ledEnabledSwitch.on ? @"YES" : @"NO");
    NSData *data = [NSData dataWithBytes:&led length:1];
    NSLog(@"Led Status value %@",data);
    [self.beaconPeripheral writeValue:data forCharacteristic:self.ledCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - Show Alert

- (void) showAlert:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
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
    isAdvancedPropertiesExist = NO;
    [self clearBasicProperties];
    [self clearAdvancedProperties];
    [self disableBasicProperties];
    [self disableAdvancedProperties];
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
                [self enableBasicProperties];
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
                [self.beaconPeripheral readValueForCharacteristic:characteristic];
                isAdvancedPropertiesExist = YES;
                [self enableAdvancedProperties];
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
        [self.uuidButton setTitle:[self decodeUUID:characteristic.value]  forState:UIControlStateNormal];
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
        NSString *manufacturingId = [NSString stringWithFormat:@"%hu",[self decodeManufacturingId:characteristic.value]];
        NSLog(@"Manufacturing Id characteristic Value: %@",manufacturingId);
        self.manufacturingIdText.enabled = YES;
        self.manufacturingIdText.text = manufacturingId;
    }
    else if ([characteristic.UUID isEqual:self.advertisingIntervalCharacteristicUUID]) {
        NSString *advertisingInterval = [NSString stringWithFormat:@"%hu",[self decodeAdvertisingInterval:characteristic.value]];
        NSLog(@"Advertising Interval characteristic Value: %@",advertisingInterval);
        self.advertisingIntervalText.enabled = YES;
        self.advertisingIntervalText.text = advertisingInterval;
    }
    else if ([characteristic.UUID isEqual:self.ledCharacteristicUUID]) {
        if ([self decodeLed:characteristic.value]) {
            NSLog(@"Led is enbled");
            self.ledEnabledSwitch.enabled = YES;
            self.ledEnabledSwitch.on = YES;
        }
        else {
            NSLog(@"Led is disabled");
            self.ledEnabledSwitch.enabled = YES;
            self.ledEnabledSwitch.on = NO;
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

#pragma mark - Show Popover

//This will show Popover when user will tap on UUID button
-(void)showPopoverOnUUID:(UIButton *)uuidButton
{
    UUIDPopoverTableViewController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IdUUIDPopOver"];
    popoverVC.modalPresentationStyle = UIModalPresentationPopover;
    popoverVC.popoverPresentationController.delegate = self;
    popoverVC.chosenUUID = [[NSUUID alloc]initWithUUIDString:self.uuidButton.titleLabel.text];
    [self presentViewController:popoverVC animated:YES completion:nil];
    
    popoverVC.popoverPresentationController.sourceView = uuidButton;
    popoverVC.popoverPresentationController.sourceRect = uuidButton.bounds;
    popoverVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverVC.preferredContentSize = CGSizeMake(300.0, 200.0);
}

//This will show Popover when user will tap on UUID button
-(void)showPopoverOnManufacturingId:(UITextField *)manufacturingIdText
{
    UUIDPopoverTableViewController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IdManufacturingIdPopOver"];
    popoverVC.modalPresentationStyle = UIModalPresentationPopover;
    popoverVC.popoverPresentationController.delegate = self;
    //popoverVC.chosenUUID = [[NSUUID alloc]initWithUUIDString:self.uuidButton.titleLabel.text];
    [self presentViewController:popoverVC animated:YES completion:nil];
    
    popoverVC.popoverPresentationController.sourceView = self.manufacturingIdText;
    popoverVC.popoverPresentationController.sourceRect = self.manufacturingIdText.bounds;
    popoverVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverVC.preferredContentSize = CGSizeMake(300.0, 200.0);
}



//implementing the protocol of UIPopoverPresentationControllerDelegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Unwind From UUIDPopoverViewController

//When user select UUID from UUIDPopoverViewController, control will return here
- (IBAction)unwindFromUUIDPopOver:(UIStoryboardSegue*)sender
{
    NSLog(@"unwindFromUUIDPopOver");
    UUIDPopoverTableViewController *uuidVC = [sender sourceViewController];
    [self.uuidButton setTitle:[uuidVC.chosenUUID UUIDString] forState:UIControlStateNormal];
    //adding delay of 1 second becuase UUIDButton text takes some time to update
    //Without delay the old UUIDButton text will be written to Beacon
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"UUID Button Title %@",self.uuidButton.titleLabel.text);
        [self updateBeaconUUID];
    });
}

- (IBAction)unwindFromManufacturingIdPopOver:(UIStoryboardSegue*)sender
{
    NSLog(@"unwindFromManufacturingIdPopOver");
    ManufacturingIdPopoverTableViewController *manufVC = [sender sourceViewController];
    if (manufVC.chosenManufacturingId > 0) {
        self.manufacturingIdText.text = [NSString stringWithFormat:@"%d", manufVC.chosenManufacturingId] ;
        //adding delay of 1 second becuase UUIDButton text takes some time to update
        //Without delay the old UUIDButton text will be written to Beacon
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Manufacturing ID before updating %@",self.manufacturingIdText.text);
            [self updateManufacturingID];
        });
    }
}


@end
