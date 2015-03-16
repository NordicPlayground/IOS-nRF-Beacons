//
//  ActionTableViewController.m
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "ActionTableViewController.h"
#import "ActionTableViewCell.h"
#import "Utility.h"

@interface ActionTableViewController ()

@end

@implementation ActionTableViewController

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
    [self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BackgroundiPhone5"]]];
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
    return [[Utility getBeaconsActions]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionDetailCell" forIndexPath:indexPath];
    cell.actionImage.image = [[Utility getBeaconsActionsImages] objectAtIndex:indexPath.row];
    cell.actionLabel.text = [[Utility getBeaconsActions] objectAtIndex:indexPath.row];
    
    if ([[[Utility getBeaconsActions] objectAtIndex:indexPath.row] isEqual:self.chosenAction]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath * selectionIndexPath = [self.tableView indexPathForSelectedRow];
    NSString *action = [[Utility getBeaconsActions] objectAtIndex:selectionIndexPath.row];
    self.chosenAction = action;
}

@end
