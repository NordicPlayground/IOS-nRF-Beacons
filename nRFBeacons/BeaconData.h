//
//  BeaconData.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 05/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconData : NSObject
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSNumber * enable;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;

@end
