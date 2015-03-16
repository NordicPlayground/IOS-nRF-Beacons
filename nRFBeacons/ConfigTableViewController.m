//
//  ConfigTableViewController.m
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "ConfigTableViewController.h"
#import "UUIDTableViewController.h"
#import "EventTableViewController.h"
#import "ActionTableViewController.h"
#import "BeaconsDatabase.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface ConfigTableViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSString *beaconName;
@property (strong, nonatomic) BeaconsDatabase *database;

@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *saveButton;
@property UIBarButtonItem *deleteButton;
@property UIBarButtonItem *cancelButton;


@end

@implementation ConfigTableViewController


BOOL isSeguePerformed, isTrashButtonPressed;

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
    NSLog(@"viewDidLoad Config");
    [self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BackgroundiPhone5"]]];    
    
    if (!self.selectedBeacon) { //Add new Beacon Default values
        NSLog(@"adding default values for new Beacon");
        self.existingBeacon = [[BeaconData alloc]init];
        self.existingBeacon.name = @"nRF Beacon";
        self.existingBeacon.uuid = [[[Utility getBeaconsUUIDS] firstObject] UUIDString];
        self.existingBeacon.major = [NSNumber numberWithInt:0];
        self.existingBeacon.minor = [NSNumber numberWithInt:0];
        self.existingBeacon.event = [[Utility getBeaconsEvents] firstObject];
        self.existingBeacon.action = [[Utility getBeaconsActions] firstObject];
        self.existingBeacon.enable = [NSNumber numberWithBool:YES];
        
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                        target:self action:@selector(doneCanceling:)];
        self.navigationItem.leftBarButtonItem = self.cancelButton;

    }
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self action:@selector(doneEditing:)];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self action:@selector(doneSaving:)];
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                    target:self action:@selector(doneDelete:)];
    
    [self showRightBarButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear Config");
    [self showStoredValuesOnView];
    isSeguePerformed = NO;
    isTrashButtonPressed = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    NSLog(@"viewWillDisappear Config");
    if (!isSeguePerformed && !self.isAddView && !isTrashButtonPressed) {
        NSLog(@"Back to Beacons from Edit View so saving beacon");
        [self updateBeacon];
    }
    else {
        NSLog(@"Segue is performed");
    }
}

-(NSManagedObjectContext *)managedObjectContext
{
    return [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

- (void) showRightBarButton
{
    if (self.isAddView) {
        NSLog(@"Add View");
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    else {
        NSLog(@"Edit View");
        self.navigationItem.rightBarButtonItem = self.deleteButton;
    }

}

- (void) showStoredValuesOnView
{
    if (self.isAddView) {
        self.nameText.text = self.existingBeacon.name;
        self.uuidLabel.text = self.existingBeacon.uuid;
        self.eventLabel.text = self.existingBeacon.event;
        self.actionLabel.text = self.existingBeacon.action;
        self.majorText.text = [NSString stringWithFormat:@"%d",[self.existingBeacon.major intValue]];
        self.minorText.text = [NSString stringWithFormat:@"%d",[self.existingBeacon.minor intValue]];
        self.enableSwitch.on = [self.existingBeacon.enable boolValue];
    }
    else {
        self.nameText.text = self.selectedBeacon.name;
        self.uuidLabel.text = self.selectedBeacon.uuid;
        self.eventLabel.text = self.selectedBeacon.event;
        self.actionLabel.text = self.selectedBeacon.action;
        self.majorText.text = [NSString stringWithFormat:@"%d",[self.selectedBeacon.major intValue]];
        self.minorText.text = [NSString stringWithFormat:@"%d",[self.selectedBeacon.minor intValue]];
        self.enableSwitch.on = [self.selectedBeacon.enable boolValue];
    }
    
}

#pragma mark - Text editing

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
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
    if (textField == self.nameText) {
        if (self.isAddView) {
            self.existingBeacon.name = self.nameText.text;
        }
        else {
            self.selectedBeacon.name = self.nameText.text;
        }
    }
    else if(textField == self.majorText)
    {
        if (self.isAddView) {
            self.existingBeacon.major = [NSNumber numberWithInt:[self.majorText.text intValue]];
        }
        else {
            self.selectedBeacon.major = [NSNumber numberWithInt:[self.majorText.text intValue]];
        }
    }
    else if(textField == self.minorText)
    {
        if (self.isAddView) {
            self.existingBeacon.minor = [NSNumber numberWithInt:[self.minorText.text intValue]];
        }
        else {
            self.selectedBeacon.minor = [NSNumber numberWithInt:[self.minorText.text intValue]];
        }
        
    }
    
    [self showRightBarButton];
}

- (IBAction)doneCanceling:(id)sender
{
    NSLog(@"doneCanceling");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneEditing:(id)sender
{
    NSLog(@"doneEditing");
    [self.majorText resignFirstResponder];
    [self.minorText resignFirstResponder];
    [self.nameText resignFirstResponder];
}

- (IBAction)doneSaving:(id)sender
{
    NSLog(@"Save button pressed on Navigation bar");
    int major = [self.majorText.text intValue];
    int minor = [self.minorText.text intValue];
    if (major > 65535 || minor > 65535) {
        [self showAlert:@"Beacon Major,Minor must be less than 65536" title:@"Error"];
        return;
    }

    self.database = [[BeaconsDatabase alloc]init];
    BeaconAddStatus addStatus = [self.database addNewBeacon:self.existingBeacon];
    if (addStatus == DUPLICATE_IN_ADD) {
        [self showAlert:@"OOPS! Another beacon with same UUID+Major+Minor combination already exist." title:@"Beacon Duplication"];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction)doneDelete:(id)sender
{
    NSLog(@"doneDelete");
    isTrashButtonPressed = YES;
    self.database = [[BeaconsDatabase alloc]init];
    [self.database deleteBeacon:self.selectedBeacon];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateBeacon
{
    NSLog(@"updateBeacon");
    self.database = [[BeaconsDatabase alloc]init];
    int major = [self.majorText.text intValue];
    int minor = [self.minorText.text intValue];
    if (major > 65535 || minor > 65535) {
        return;
    }
    BeaconUpdateStatus updateStatus = [self.database updateBeacon:self.selectedBeacon];
    if (updateStatus == DUPLICATE_IN_UPDATE) {        
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSague in ConfigViewController");
    isSeguePerformed = YES;
    if ([segue.identifier isEqualToString:@"UuidSegue"]) {
        UUIDTableViewController *uuidVC = [segue destinationViewController];
        if (self.isAddView) {
            uuidVC.chosenUUID = [[NSUUID alloc]initWithUUIDString:self.existingBeacon.uuid];
        }
        else {
            uuidVC.chosenUUID = [[NSUUID alloc]initWithUUIDString:self.selectedBeacon.uuid];
        }
        
    } else if ([segue.identifier isEqualToString:@"EventSegue"]) {
        EventTableViewController *eventVC = [segue destinationViewController];
        if (self.isAddView) {
            eventVC.chosenEvent = self.existingBeacon.event;
        }
        else {
            eventVC.chosenEvent = self.selectedBeacon.event;
        }

        
    } else if ([segue.identifier isEqualToString:@"ActionSegue"]) {
        ActionTableViewController *actionVC = [segue destinationViewController];
        if (self.isAddView) {
            actionVC.chosenAction = self.existingBeacon.action;
        }
        else {
            actionVC.chosenAction = self.selectedBeacon.action;
        }
        
    }
    
}

- (IBAction)unwindUUIDSelector:(UIStoryboardSegue*)sender
{
    UUIDTableViewController *uuidVC = [sender sourceViewController];
    if (self.isAddView) {
        self.existingBeacon.uuid = [uuidVC.chosenUUID UUIDString];
    }
    else {
        self.selectedBeacon.uuid = [uuidVC.chosenUUID UUIDString];
    }
    
}

- (IBAction)unwindEventSelector:(UIStoryboardSegue*)sender
{
    EventTableViewController *eventVC = [sender sourceViewController];
    if (self.isAddView) {
        self.existingBeacon.event = eventVC.chosenEvent;
    }
    else {
        self.selectedBeacon.event = eventVC.chosenEvent;
    }
}

- (IBAction)unwindActionSelector:(UIStoryboardSegue*)sender
{
    ActionTableViewController *actionVC = [sender sourceViewController];
    if (self.isAddView) {
        self.existingBeacon.action = actionVC.chosenAction;
    }
    else {
        self.selectedBeacon.action = actionVC.chosenAction;
    }
}

- (IBAction)enableSwitchChanged:(UISwitch *)sender {
    NSLog(@"enableSwitchChanged, State: %@",sender.on ? @"YES" : @"NO");
    if (self.isAddView) {
        self.existingBeacon.enable = [NSNumber numberWithBool:sender.on];
    }
    else {
        self.selectedBeacon.enable = [NSNumber numberWithBool:sender.on];
    }
}

-(NSString *) getSectionHeaderText:(int)sectionIndex
{
    NSLog(@"section index %d",sectionIndex);
    switch (sectionIndex) {
        case 0:
            return @"NAME";
        case 1:
            return @"IDENTITY";
        case 2:
            return @"NOTIFY";
        case 3:
            return @"STATUS";
            
        default:
            return @"Invalid Section Index";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
     UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
     if ((int)section == 0) {
         return headerView;
     }
     UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.bounds.size.width-40, 25)];
     sectionLabel.text = [self getSectionHeaderText:(int)section];
     sectionLabel.textColor = [UIColor whiteColor];
     sectionLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:15.0];
     sectionLabel.textAlignment = NSTextAlignmentCenter;
     sectionLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.85 alpha:1.0];
     [headerView addSubview:sectionLabel];     
     return headerView;
}

@end
