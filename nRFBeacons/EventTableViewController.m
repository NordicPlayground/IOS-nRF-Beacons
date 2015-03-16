//
//  EventTableViewController.m
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "EventTableViewController.h"
#import "EventTableViewCell.h"
#import "Utility.h"

@interface EventTableViewController ()

@end

@implementation EventTableViewController

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
    return [[Utility getBeaconsEvents]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailCell" forIndexPath:indexPath];
    cell.eventLabel.text = [[Utility getBeaconsEvents] objectAtIndex:indexPath.row];
    cell.eventImage.image = [[Utility getBeaconsEventsImages] objectAtIndex:indexPath.row];
    
    if ([[[Utility getBeaconsEvents] objectAtIndex:indexPath.row] isEqual:self.chosenEvent]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath * selectionIndexPath = [self.tableView indexPathForSelectedRow];
    NSString *event = [[Utility getBeaconsEvents] objectAtIndex:selectionIndexPath.row];
    self.chosenEvent = event;
}

@end
