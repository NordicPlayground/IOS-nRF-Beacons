//
//  UpdateScanTableViewController.m
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 13/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "UpdateScanTableViewController.h"

@interface UpdateScanTableViewController ()
@property (strong, nonatomic)NSMutableArray *beaconPeripherals;
@property (strong, nonatomic)NSArray *beacons;
@property (strong, nonatomic)CBUUID *beaconServiceUUID;
@property (strong,nonatomic)CBCentralManager *bluetoothManager;
@end

@implementation UpdateScanTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad UpdateScan");
    [self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BackgroundiPhone5"]]];
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.beaconPeripherals = [[NSMutableArray alloc]init];
    self.beacons = [[NSArray alloc]init];
    self.beaconServiceUUID = [CBUUID UUIDWithString:@"955A1523-0FE2-F5AA-A094-84B8D4F3E8AD"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{       
    return [self.beacons count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scanCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.beacons objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row selected");
    [self.bluetoothManager stopScan];
    [self.scanDelegate selectedPeripheral:[self.beacons objectAtIndex:indexPath.row] centralManager:self.bluetoothManager];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender {    
    NSLog(@"Cancel bar button pressed");
    [self.bluetoothManager stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];    
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState");
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [self.bluetoothManager scanForPeripheralsWithServices:[NSArray arrayWithObject:self.beaconServiceUUID] options:nil];
    }
    else
    {
        return;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"didDiscoverPeripheral %@",peripheral.name);
    [self.beaconPeripherals addObject:peripheral];
    self.beacons = [NSArray arrayWithArray:self.beaconPeripherals];
    [self.tableView reloadData];
}

@end
