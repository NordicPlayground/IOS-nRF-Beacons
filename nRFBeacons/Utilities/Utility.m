/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

+ (BOOL)isApplicationStateInactiveORBackground {
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
