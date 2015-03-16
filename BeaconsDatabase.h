//
//  BeaconsDatabase.h
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 04/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconData.h"
#import "Beacons.h"
#import "Utility.h"

@interface BeaconsDatabase : NSObject

- (BeaconUpdateStatus) updateBeacon:(Beacons *)beacon;
- (NSArray *) readAllBeacons;
- (void) deleteBeacon:(Beacons *)beacon;
- (BeaconAddStatus) addNewBeacon:(BeaconData *)beacon;

@end
