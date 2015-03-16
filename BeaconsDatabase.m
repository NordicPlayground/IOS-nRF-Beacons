//
//  BeaconsDatabase.m
//  nRFBeacons
//
//  Created by Nordic Semiconductor on 04/03/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "BeaconsDatabase.h"
#import "AppDelegate.h"
#import "Beacons.h"
#import "Utility.h"

@implementation BeaconsDatabase
{
    AppDelegate *_appDelegate;
    NSManagedObjectContext *_context;
    BeaconUpdateStatus updateStatus;
    BeaconAddStatus addStatus;
}

- (id) init
{
    self = [super init];
    if (self) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        _context = [_appDelegate managedObjectContext];
    }
    return self;
}

- (BeaconUpdateStatus) updateBeacon:(Beacons *)beacon;
{
    //Check if UUID+Major+Minor combination already exist in database
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacons" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(uuid = %@) AND (major = %@) AND (minor = %@)"
                               ,beacon.uuid,beacon.major,beacon.minor];
    [request setPredicate:predSearch];
    NSError *error;
    NSArray *matchingRecords = [_context executeFetchRequest:request error:&error];
    if (matchingRecords) {
        NSLog(@"number of similar Records: %lu",(unsigned long)matchingRecords.count);
        if (matchingRecords.count > 1) {
            NSLog(@"No update: Duplication has found in Beacons");
            updateStatus = DUPLICATE_IN_UPDATE;
        }
        else {
            NSLog(@"No Duplication has found in Beacons, updating ...");
            Beacons *existingBeacon = [matchingRecords lastObject];
            [existingBeacon setValue:beacon.name forKey:@"name"];
            [existingBeacon setValue:beacon.uuid forKey:@"uuid"];
            [existingBeacon setValue:beacon.major forKey:@"major"];
            [existingBeacon setValue:beacon.minor forKey:@"minor"];
            [existingBeacon setValue:beacon.event forKey:@"event"];
            [existingBeacon setValue:beacon.action forKey:@"action"];
            [existingBeacon setValue:beacon.enable forKey:@"enable"];
            
            NSError *saveError;
            if (![_context save:&saveError]) {
                NSLog(@"Error updating Beacon in Phone");
                updateStatus = ERROR_IN_UPDATE;
            }
            else {
                NSLog(@"Beacon is updated in Phone");
                updateStatus = UPDATED_SUCCESSFULLY;
            }
        }
    }
    else {
        NSLog(@"No matching Beacon has found in database");
        updateStatus = BEACON_NOT_FOUND_IN_UPDATE;
    }
    return updateStatus;    
    }

- (BeaconAddStatus) addNewBeacon:(BeaconData *)beacon
{
    NSLog(@"AddNewBeacon");
    NSLog(@"uuid: %@",beacon.uuid);
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacons" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(uuid = %@) AND (major = %@) AND (minor = %@)"
                               ,beacon.uuid,beacon.major,beacon.minor];
    [request setPredicate:predSearch];
    NSError *error;
    Beacons *existingBeacon = [[_context executeFetchRequest:request error:&error]lastObject];
    if (existingBeacon) {
        NSLog(@"Cant add beacon. it is already present");
        addStatus = DUPLICATE_IN_ADD;
    }
    else {
        [self add:beacon];
        NSError *saveError;
        if (![_context save:&saveError]) {
            NSLog(@"Error adding Beacon in Phone");
            addStatus = ERROR_IN_ADD;
        }
        else {
            NSLog(@"Beacon is added in Phone");
            addStatus = ADDED_SUCCESSFULLY;
        }
    }
    return addStatus;
}

-(void)deleteBeacon:(Beacons *)beacon
{
    [_context deleteObject:beacon];
    
    NSError *saveError;
    if (![_context save:&saveError]) {
        NSLog(@"Error removing beacon from Phone");
    }
    else {
        NSLog(@"Beacon is removed from Phone");
    }
}

-(NSArray *) readAllBeacons
{
    [_context rollback];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacons" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *records = [_context executeFetchRequest:request error:&error];
    if ([records count] == 0) {
        NSLog(@"No Beacon is saved in Phone");
        return nil;
    }
    else {
        return records;
    }
}

-(void) add:(BeaconData *)beacon
{
    NSLog(@"Beacon is new. adding ...");
    Beacons *newBeacon = (Beacons *)[NSEntityDescription insertNewObjectForEntityForName:@"Beacons" inManagedObjectContext:_context];
    [newBeacon setValue:beacon.uuid forKey:@"uuid"];
    [newBeacon setValue:beacon.name forKey:@"name"];
    [newBeacon setValue:beacon.major forKey:@"major"];
    [newBeacon setValue:beacon.minor forKey:@"minor"];
    [newBeacon setValue:beacon.event forKey:@"event"];
    [newBeacon setValue:beacon.action forKey:@"action"];
    [newBeacon setValue:beacon.enable forKey:@"enable"];
}

@end
