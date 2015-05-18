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

#import <AVFoundation/AVFoundation.h>
#import "BeaconsViewController.h"
#import "BeaconTableViewCell.h"
#import "BeaconsDatabase.h"
#import "Beacons.h"
#import "ConfigTableViewController.h"
#import "MonalisaViewController.h"
#import "Reachability.h"
#import "PopoverViewController.h"

@interface BeaconsViewController ()
{
    BOOL isAppInBackground, isActionPerformed, shouldStopAction;
}
@property (nonatomic, strong)NSArray *beacons;
@property (strong, nonatomic) BeaconsDatabase *database;
@property (strong, nonatomic) NSUUID *beaconUUID;
@property (strong, nonatomic) BeaconData *beaconData;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSMutableArray *regions;
@property (strong, nonatomic) NSMutableArray *beaconsRange;
@end

@implementation BeaconsViewController

@synthesize locationManager;
@synthesize audioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad Beacons");
    self.beaconsTableView.dataSource = self;
    self.database = [[BeaconsDatabase alloc]init];
    locationManager = [[CLLocationManager alloc]init];
    // New iOS 8 request for Always Authorization, required for iBeacons to work!
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.delegate = self;
    isAppInBackground = NO;
    [self initSound];
    
    self.regions = [[NSMutableArray alloc]initWithCapacity:[[Utility getBeaconsUUIDS] count]];
    for (int index = 0; index < [[Utility getBeaconsUUIDS] count]; index++)
    {
        [self.regions addObject:[NSNull null]];
    }
    
    [self.beaconsTableView setTableFooterView:[UIView new]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear Beacons");
    //Enable Action when view get appeared
    shouldStopAction = NO;
    [self reloadBeacons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    NSLog(@"viewWillDisappear Beacons");
    //Disable Action when view is disappeared
    shouldStopAction = YES;
}

-(void)reloadBeacons
{
    self.beacons = [self.database readAllBeacons];
    
    [self.beaconsTableView reloadData];
    //This will put a delay of 5 seconds between Action trigger.
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (shouldStopAction) { //If the view is disappeared then dont perfom Action
            isActionPerformed = YES;
        }
        else { //if the view is appeared then perform Action
            isActionPerformed = NO;
        }
    });

    
    self.beaconsRange = [[NSMutableArray alloc] initWithCapacity:[self.beacons count]];
    for (int index = 0; index < [self.beacons  count]; index++)
    {
        [self.beaconsRange addObject:[NSNull null]];
    }
    /*
     * Create Regions for each unique Beacon UUID provided in the app and these should be fixed and known
     * and assign each region unique identifier
     * if Beacon is saved with one of these provided UUIDs then register Region having that UUID
     * Unregister Region if there is not any saved or enabled Beacon found having that UUID
     */
    
    for(int regionIndex = 0; regionIndex < [[Utility getBeaconsUUIDS]count]; regionIndex++ )
    {
        BOOL isBeaconFound = NO;
        BOOL isBeaconEnable = NO;
        
        for(int beaconIndex = 0; beaconIndex < [self.beacons count]; beaconIndex++)
        {
            if ([[[[Utility getBeaconsUUIDS] objectAtIndex:regionIndex] UUIDString]
                 caseInsensitiveCompare:[[self.beacons objectAtIndex:beaconIndex]uuid]]==NSOrderedSame) {
                isBeaconFound = YES;
                if ([[(Beacons *)[self.beacons objectAtIndex:beaconIndex]enable]boolValue]) {
                    isBeaconEnable = YES;
                }
            }
        }
        //if Beacon/Beacons Found in Region (regionIndex) and
        //atleast one Beacon is enabled in that Region then check the corresponding Region
        // if Region is not exist already then create Region and start Monitoring and Ranging
        if (isBeaconFound && isBeaconEnable) {
            NSLog(@"Atleast one Beacon is enable in Region %d with UUID %@",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            if ([[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Creating Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [self.regions replaceObjectAtIndex:regionIndex withObject:[Utility getRegionAtIndex:regionIndex]];
                [locationManager startMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager startRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
            }
            else {
                NSLog(@"Region %d already exist with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            }
            
        }
        // if NO Beacon found or No Beacon is enable in Region (regionIndex) then check the corresponding Region
        // if Region exist already then stop Monitoring and Ranging and assign nil to Region
        else {
            NSLog(@"No beacon is found or enable in Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            
            if (![[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Region %d with UUID %@ already exist and now removing it",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [locationManager stopMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager stopRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
                [self.regions replaceObjectAtIndex:regionIndex withObject:[NSNull null]];
            }
        }
    }

}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    isAppInBackground = YES;
    NSLog(@"App is in background");
}

-(void)appDidBecomeActiveBackground:(NSNotification *)_notification
{
    isAppInBackground = NO;
    NSLog(@"App is in foreground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initSound
{
    NSError *error  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"low" ofType:@"aiff"]];
    audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        [audioPlayer prepareToPlay];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSections");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberofRows: %lu",(unsigned long)self.beacons.count);
    if (self.beacons.count == 0) {
        [self setEmptyTableMessage];
    }
    return self.beacons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.hidden = NO;
    self.emptyMessageText.hidden = YES;
    BeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];
    Beacons *beacon = [self.beacons objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.beaconActionImage.image = [self getActionImage:beacon.action];
    
    if ([beacon.enable boolValue]) {
        [cell.beaconRange setTextColor:[UIColor blackColor]];
        [cell.beaconName setTextColor:[UIColor blackColor]];
        cell.beaconName.text = [NSString stringWithFormat:@"%@",beacon.name];
        cell.beaconRange.text = [self getBeaconRange:[self.beaconsRange objectAtIndex:indexPath.row]];
    }
    else {
        [cell.beaconName setTextColor:[UIColor lightGrayColor]];
        cell.beaconName.text = [NSString stringWithFormat:@"%@",beacon.name];
        [cell.beaconRange setTextColor:[UIColor lightGrayColor]];
        cell.beaconRange.text = @"OFF";
    }
    return cell;
}

- (void) setEmptyTableMessage
{
    self.beaconsTableView.hidden = YES;
    self.emptyMessageText.hidden = NO;
    self.emptyMessageText.editable = YES;
    [self.emptyMessageText setFont:[UIFont systemFontOfSize:20.0]];
    self.emptyMessageText.text = [NSString stringWithFormat:@"Please tap + on Navigation bar to add Nordic Semiconductor Beacon or Other Beacon with specific UUIDS."];
    self.emptyMessageText.editable = NO;
}

-(NSString *)getBeaconRange:(NSNumber *)range
{
    if ([range isEqual:[NSNull null]]) {
        return @"Beacon Not Found";
    }
    switch([range intValue]) {
        case 0:
            return @"At beacon";
        case 1:
            return @"Near";
        case 2:
            return @"Far";
        case 3:
            return @"Unknown";
        default:
            return @"Invalid Location";
    }
    
}

-(UIImage *) getActionImage:(NSString *)imageName
{
    if ([imageName isEqualToString:@"Show Mona Lisa"]) {
        return [UIImage imageNamed:@"Monalisa"];
    }
    if ([imageName isEqualToString:@"Open Website"]) {
        return [UIImage imageNamed:@"Website"];
    }
    if ([imageName isEqualToString:@"Run Application"]) {
        return [UIImage imageNamed:@"Application"];
    }
    if ([imageName isEqualToString:@"Play Alarm"]) {
        return [UIImage imageNamed:@"Alarm"];
    }
    if ([imageName isEqualToString:@"Silent Phone"]) {
        return [UIImage imageNamed:@"SilentPhone"];
    }
    return nil;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit"]) {        
        NSIndexPath * selectionIndexPath = [self.beaconsTableView indexPathForSelectedRow];
        Beacons *beacon = [self.beacons objectAtIndex:selectionIndexPath.row];
        ConfigTableViewController *configVC = [segue destinationViewController];
        configVC.selectedBeacon = beacon;        
        configVC.isAddView = NO;
    }
}

-(void)showBackgroundAlert:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertAction = @"Show";
    notification.alertBody = message;
    notification.hasAction = NO;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone  defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

-(void)showForegroundAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"nRF Beacons" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showMonalisa
{
    [self performSegueWithIdentifier:@"MonalisaSegue" sender:self];
}

- (void)openWebsite
{
    if ([self isInternetConnectionAvailable]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.nordicsemi.com"]];
    }
    else {
        [self showForegroundAlert:@"Internet connection not availble to open website"];
    }
}

- (void)playAlarm
{
    [audioPlayer play];
}

- (BOOL)isInternetConnectionAvailable
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"NO internet connection");
        return NO;
    } else {
        
        NSLog(@"internet connection available");
        return YES;
    }        
}

#pragma mark - CLLocationManager delegates

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"*****didEnterRegion******");
    
    [self performActionForEvent:EventEnter withIdentifier:region.identifier];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"***********didExitRegion***********");
    [self performActionForEvent:EventExit withIdentifier:region.identifier];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringForRegion");
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"didRangeBeacons");
    if ([beacons count] > 0) {
        NSLog(@"beacons founds: %lu",(unsigned long)[beacons count]);
        CLBeacon *beacon = [beacons objectAtIndex:0]; 
        
        
        NSLog(@"Beacons UUID: %@",beacon.proximityUUID);
        NSLog(@"Beacons Major: %@",beacon.major);
        NSLog(@"Beacons Minor: %@",beacon.minor);
        
        
        for(int i = 0; i < [beacons count]; i++) //scanned beacons in Ranging
        {
            for(int j=0; j<[self.beacons count]; j++) //stored beacons in database
            {
                if (([[[beacons[i] proximityUUID] UUIDString] caseInsensitiveCompare:[self.beacons[j] uuid]]==NSOrderedSame) &&
                    ([[beacons[i] major] unsignedShortValue] == [[self.beacons[j] major] unsignedShortValue]) &&
                    ([[beacons[i] minor] unsignedShortValue] == [[self.beacons[j] minor] unsignedShortValue]) &&
                    ([[(Beacons *)self.beacons[j] enable]boolValue]))
                {
                    NSLog(@"Found Beacon and enabled");
                    NSLog(@"Beacon UUID: %@",[beacons[i] proximityUUID]);
                    NSLog(@"Beacon Major: %@",[beacons[i] major]);
                    NSLog(@"Beacon Minor: %@",[beacons[i] minor]);
                    
                    //Finding Scanned Beacon Proximity and converting it to the Event of stored Beacon
                    if ([beacons[i] proximity] == CLProximityImmediate) {
                        NSLog(@"Immidiate Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:At_Beacon]];
                        [self.beaconsTableView reloadData];
                        if ([[self.beacons[j] event] isEqualToString:EventImmidiate]) {
                            NSLog(@"Close Event matched");
                            [self performAction:[(Beacons *)self.beacons[j] action]];
                        }
                    }
                    else if ([beacons[i] proximity] == CLProximityNear) {
                        NSLog(@"Near Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:NEAR]];
                        [self.beaconsTableView reloadData];
                        if ([[self.beacons[j] event] isEqualToString:EventNear]) {
                            NSLog(@"Near Event matched");
                            [self performAction:[(Beacons *)self.beacons[j] action]];
                        }
                    }
                    else if ([beacons[i] proximity] == CLProximityFar) {
                        NSLog(@"Far Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:FAR]];
                        [self.beaconsTableView reloadData];
                    }
                    else if ([beacons[i] proximity] == CLProximityUnknown) {
                        NSLog(@"Unknown Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:UNKNOWN]];
                        [self.beaconsTableView reloadData];

                    }

                }
            }
        }
        
    }
    else {
        NSLog(@"No beacon found!");
    }
}

//Perform actions on Ranging Events Near and Close
- (void)performAction:(NSString *)action
{
    if(!isActionPerformed) {
        if([action isEqualToString:@"Show Mona Lisa"]) {
            NSLog(@"showMonalisa");
            if (isAppInBackground) {
                [self showBackgroundAlert:@"Mona Lisa"];
            }
            [self showMonalisa];
            isActionPerformed = YES;
        }
        else if([action isEqualToString:@"Open Website"]) {
            NSLog(@"Open Website");
            [self openWebsite];
            if (isAppInBackground) {
                [self showBackgroundAlert:@"Nordic Semiconductor"];
            }
            isActionPerformed = YES;
        }
        else if([action isEqualToString:@"Play Alarm"]) {
            NSLog(@"Playing Alarm");
            [self playAlarm];
            if (isAppInBackground) {
                [self showBackgroundAlert:@"Playing Alarm"];
            }
            isActionPerformed = YES;
        }
    }
}

//Perform actions for Regions event Enter and Exit
- (void)performActionForEvent:(NSString *)event withIdentifier:(NSString *)identifier
{
    NSString *regionUUIDFromIdentifier = [self getRegionUUIDFromIdentifier:identifier];
    NSLog(@"Performing action for event: %@ RegionUUID %@",event,regionUUIDFromIdentifier);
    for(int index = 0; index < [self.beacons count]; index ++)
    {
        if (([[self.beacons[index] uuid] caseInsensitiveCompare:regionUUIDFromIdentifier]==NSOrderedSame)  &&
            ([[(Beacons *)self.beacons[index] enable]boolValue])) {
            NSLog(@"*******Beaon found with Exit or Enter Event Now changing Ranging Status to nil ***********");
            [self.beaconsRange replaceObjectAtIndex:index withObject:[NSNull null]];
            [self.beaconsTableView reloadData];
            if ([[self.beacons[index] event] isEqualToString:event]) {
                if ([[self.beacons[index] action] isEqualToString:@"Show Mona Lisa"]) {
                    NSLog(@"showMonalisa");
                    if (isAppInBackground) {
                        [self showBackgroundAlert:@"Mona Lisa"];
                    }
                    [self showMonalisa];
                    return;
                }
                else if ([[self.beacons[index] action] isEqualToString:@"Open Website"]) {
                    NSLog(@"Open Website");
                    if (isAppInBackground) {
                        [self showBackgroundAlert:@"Nordic Semiconductor ASA"];
                    }
                    [self openWebsite];
                    return;
                }
                else if ([[self.beacons[index] action] isEqualToString:@"Play Alarm"]) {
                    NSLog(@"Playing Alarm");
                    if (isAppInBackground) {
                        [self showBackgroundAlert:@"Playing Alarm"];
                    }
                    [self playAlarm];
                    return;
                }
            }
        }
    }
    
}

- (NSString *) getRegionUUIDFromIdentifier:(NSString *)regionIdentifier
{
    if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 1"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:0]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 2"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:1]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 3"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:2]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 4"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:3]UUIDString];
    }
    return nil;
}

//Adding Popover when Add '+' button is pressed
- (IBAction)AddButtonPressed:(UIBarButtonItem *)sender {
    [self showPopoverOn:self.addBarButton];
}

//This will show Popover when user will tap on Add '+' button
-(void)showPopoverOn:(UIBarButtonItem *)barButton
{
    PopoverViewController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IdPopoverViewController"];
    popoverVC.modalPresentationStyle = UIModalPresentationPopover;
    popoverVC.popoverPresentationController.delegate = self;
    popoverVC.popOverDelegate = self;
    [self presentViewController:popoverVC animated:YES completion:nil];
    
    popoverVC.popoverPresentationController.barButtonItem = barButton;
    popoverVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverVC.preferredContentSize = CGSizeMake(200.0, 100.0);
}

//implementing the mthods of UIPopoverPresentationControllerDelegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - PopOverWillDismissDelegate 

// Implementing the method of  protocol PopOverWillDismissDelegate
-(void) popOverWillDismiss
{
    [self reloadBeacons];
}

@end
