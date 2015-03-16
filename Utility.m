//
//  Utility.m
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 06/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "Utility.h"

@implementation Utility

NSString* const EventImmidiate = @"At beacon";
NSString* const EventNear = @"Near";
NSString* const EventExit = @"Out of Range";
NSString* const EventEnter = @"In Range";


+ (NSArray *) getBeaconsEvents
{
    static NSArray *events;
    if (events == nil) {        
        events = @[EventImmidiate, EventNear, EventExit, EventEnter];
    }
    return events;
}

+ (NSArray *) getBeaconsActions
{
    static NSArray *actions;
    if (actions == nil) {
        actions = @[@"Show Mona Lisa", @"Open Website", @"Play Alarm"];
    }
    return actions;
}

+ (CLBeaconRegion *) getRegionAtIndex:(int)regionIndex
{
    switch(regionIndex) {
        case 0:
            return [[CLBeaconRegion alloc] initWithProximityUUID:[[Utility getBeaconsUUIDS]objectAtIndex:0]
                                                      identifier:[NSString stringWithFormat:@"Nordic Semiconductor ASA 1"]];
        case 1:
            return [[CLBeaconRegion alloc] initWithProximityUUID:[[Utility getBeaconsUUIDS]objectAtIndex:1]
                                                      identifier:[NSString stringWithFormat:@"Nordic Semiconductor ASA 2"]];
        case 2:
            return [[CLBeaconRegion alloc] initWithProximityUUID:[[Utility getBeaconsUUIDS]objectAtIndex:2]
                                                      identifier:[NSString stringWithFormat:@"Nordic Semiconductor ASA 3"]];
        case 3:
            return [[CLBeaconRegion alloc] initWithProximityUUID:[[Utility getBeaconsUUIDS]objectAtIndex:3]
                                                      identifier:[NSString stringWithFormat:@"Nordic Semiconductor ASA 4"]];
        default:
            return nil;
            
    }
}

+ (NSArray *) getBeaconsUUIDS
{
    static NSArray *uuids;
    if (uuids == nil) {
        uuids = @[[[NSUUID alloc] initWithUUIDString:@"01122334-4556-6778-899A-ABBCCDDEEFF0"],
                  [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
                  [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
                  [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"]];
    }
    return uuids;
}

/*  Note: In database only Beacon Action name is stored and
 *  Action image is obtained by manually matching the Action
 *  name with Action image in file BeaconsViewController
 */
+ (NSArray *) getBeaconsActionsImages
{
    static NSArray *actionImages;
    if (actionImages == nil) {
        actionImages = @[[UIImage imageNamed:@"Monalisa"],
                         [UIImage imageNamed:@"Website"],
                         [UIImage imageNamed:@"Alarm"]];
    }
    return actionImages;
}

/*  Note: In database only Beacon Event name is stored and
 *  Event image is obtained by manually matching the Event
 *  name with Event image in file BeaconsViewController
 */
+ (NSArray *) getBeaconsEventsImages
{
    static NSArray *eventImages;
    if (eventImages == nil) {
        eventImages = @[[UIImage imageNamed:@"ImmidiateRange"],
                        [UIImage imageNamed:@"NearRange"],
                        [UIImage imageNamed:@"OutRange"],
                        [UIImage imageNamed:@"InRange"],
                        
                        ];
    }
    return eventImages;
}

@end
