//
//  UUIDPopoverTableViewController.m
//  nRFBeacons
//
//  Created by Kamran Saleem Soomro on 11/02/15.
//  Copyright (c) 2015 Nordic Semiconductor. All rights reserved.
//

#import "UUIDPopoverTableViewController.h"
#import "Utility.h"

@interface UUIDPopoverTableViewController ()

@end

@implementation UUIDPopoverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [[Utility getBeaconsUUIDS]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UUIDDetailCell" forIndexPath:indexPath];
    if ([[[Utility getBeaconsUUIDS] objectAtIndex:indexPath.row] isEqual:self.chosenUUID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.text = [[[Utility getBeaconsUUIDS]objectAtIndex:indexPath.row]UUIDString];
    return cell;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath * selectionIndexPath = [self.tableView indexPathForSelectedRow];
    NSUUID *uuid = [[Utility getBeaconsUUIDS] objectAtIndex:selectionIndexPath.row];
    self.chosenUUID = uuid;
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
