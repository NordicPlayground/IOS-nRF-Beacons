//
//  ManufacturingIdPopoverTableViewController.h
//  nRFBeacons
//
//  Created by Kamran Saleem Soomro on 18/02/15.
//  Copyright (c) 2015 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManufacturingIdPopoverTableViewController : UITableViewController

- (IBAction)doneButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *manufacturingIdText;
@property (nonatomic)int chosenManufacturingId;
@end
