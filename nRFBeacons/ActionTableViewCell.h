//
//  ActionTableViewCell.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 03/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *actionImage;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@end
