//
//  BeaconsViewController.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PopoverViewController.h"

@interface BeaconsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, PopOverWillDismissDelegate>
@property (weak, nonatomic) IBOutlet UITableView *beaconsTableView;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextView *emptyMessageText;

- (IBAction)AddButtonPressed:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButton;

@end
