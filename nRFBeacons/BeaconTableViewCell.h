//
//  BeaconTableViewCell.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *beaconActionImage;
@property (weak, nonatomic) IBOutlet UILabel *beaconName;
@property (weak, nonatomic) IBOutlet UILabel *beaconRange;

@end
