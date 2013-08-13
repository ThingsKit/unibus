//
//  CHDataLoader.m
//  Warwick Unibus
//
//  Created by Chris Howell on 31/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHDataLoader.h"
#import "BusStop.h"
#import "BusTime.h"
#import "CoreData+MagicalRecord.h"

@interface CHDataLoader()
@end

@implementation CHDataLoader

static CHDataLoader *sharedDataLoader = nil;    // static instance variable

+(CHDataLoader*)sharedDataLoader
{
    if (sharedDataLoader == nil) {
        sharedDataLoader = [[super alloc] init];
    }
    return sharedDataLoader;
}

+(BusStop*)busStopWithId:(NSNumber *)id
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];

    NSFetchRequest *existentialCheck = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BusStop" inManagedObjectContext:localContext];
    [existentialCheck setEntity:entity];
    [existentialCheck setPredicate:[NSPredicate predicateWithFormat:@"stop_id=%@", id]];
    
    NSError *error;
    NSArray *fetchedObjects = [localContext executeFetchRequest:existentialCheck error:&error];
    
    BusStop *busStop = nil;
    
    busStop = [fetchedObjects lastObject];
    return busStop;
}

-(void)loadData
{
    [self loadBusData];
}

-(void)loadBusData
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSError *e = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[@"busstops.json" stringByDeletingPathExtension] ofType:[@"busstops.json" pathExtension]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        for(NSDictionary *item in jsonArray) {
            
            // Check if bus stop already exists
            NSFetchRequest *existentialCheck = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"BusStop" inManagedObjectContext:localContext];
            [existentialCheck setEntity:entity];
            [existentialCheck setPredicate:[NSPredicate predicateWithFormat:@"stop_id=%@", [item objectForKey:@"id"]]];
            
            NSError *error;
            NSArray *fetchedObjects = [localContext executeFetchRequest:existentialCheck error:&error];
            
            BusStop *busStop = nil;
            
            busStop = [fetchedObjects lastObject];
            if (!busStop) {
                // create
                busStop = [NSEntityDescription
                               insertNewObjectForEntityForName:@"BusStop"
                               inManagedObjectContext:localContext];
                
                busStop.stop_id = [item objectForKey:@"id"];
                busStop.name = [item objectForKey:@"name"];
                busStop.latitude = [NSNumber numberWithDouble:[[item objectForKey:@"latitude"] doubleValue]];
                busStop.longitude = [NSNumber numberWithDouble:[[item objectForKey:@"longitude"] doubleValue]];
            }
        
        }
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            [self loadTimetableData];
        }];  //saves the context to disk
        
    }

    
}

-(void)loadTimetableData
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSError *e = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[@"all_times.json" stringByDeletingPathExtension] ofType:[@"all_times.json" pathExtension]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        for(NSDictionary *item in jsonArray) {
          // Check if bus stop already exists
            //NSArray *results = [BusTime MR_findByAttribute:@"stop_id" withValue:[item objectForKey:@"id"]];   // Query to find the first person store into the databe
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop_id ==[c] %@ AND time LIKE[c] %@ AND destination LIKE[c] %@ AND period LIKE[c] %@ AND number LIKE[c] %@", [item objectForKey:@"id"], [item objectForKey:@"time"], [item objectForKey:@"destination"], [item objectForKey:@"period"], [item objectForKey:@"busNo"]];
            BusTime *busTime = [BusTime MR_findFirstWithPredicate:predicate inContext:localContext];
            //NSLog(@"%@",predicate);
            
            if (!busTime) {
                // create
                
                BusTime *time = [BusTime MR_createInContext:localContext];
                time.time = [item objectForKey:@"time"];
                time.stop_id = [item objectForKey:@"id"];
                time.period = [item objectForKey:@"period"];
                time.number = [item objectForKey:@"busNo"];
                time.destination = [item objectForKey:@"destination"];
                
                
                BusStop *stop = [[BusStop MR_findByAttribute:@"stop_id" withValue:[item objectForKey:@"id"]] firstObject];
                [stop.timetableSet addObject:time];
            }else {
//                NSLog(@"BusTime already exists: %@, %@, %@", busTime.stop_id, busTime.destination, busTime.time);
            }
            
        }
        
    }
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *e) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"coreDataUpdated" object:self];
    }];

    NSArray *objects = [BusTime MR_findAll];
    NSLog(@"Time objects in: %i", jsonArray.count);
    NSLog(@"Time objects out: %i", objects.count);
}

@end
