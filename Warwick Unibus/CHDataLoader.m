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
@property (nonatomic, strong) NSArray *reference_stops;
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
    NSLog(@"Error parsing JSON: %@", e);
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        BusTime *previousTime = nil;
        int count = 0;
        int sequence = 1;
        for(NSDictionary *item in jsonArray) {
          // Check if bus stop already exists
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop_id ==[c] %@ AND time LIKE[c] %@ AND destination LIKE[c] %@ AND period LIKE[c] %@ AND number LIKE[c] %@", [item objectForKey:@"id"], [[item objectForKey:@"time"] stringByReplacingOccurrencesOfString:@":" withString:@""], [item objectForKey:@"destination"], [item objectForKey:@"period"], [item objectForKey:@"busNo"]];
            BusTime *busTime = [BusTime MR_findFirstWithPredicate:predicate inContext:localContext];
            //NSLog(@"%@",predicate);
            if (!busTime) {
                // create
                
                BusTime *time = [BusTime MR_createInContext:localContext];
                time.time = [[item objectForKey:@"time"] stringByReplacingOccurrencesOfString:@":" withString:@""];
                time.stop_id = [item objectForKey:@"id"];
                time.period = [item objectForKey:@"period"];
                time.number = [item objectForKey:@"busNo"];
                time.destination = [item objectForKey:@"destination"];
                time.sequenceNo = [NSNumber numberWithInt:sequence];
                
                // First edge case
                if (previousTime == nil) {
                    time.firstBus = [NSNumber numberWithBool:YES];
                } else if (count == jsonArray.count) {
                    time.lastBus = [NSNumber numberWithBool:YES];
                } else if (![previousTime.stop_id isEqualToNumber:time.stop_id]) {
                    previousTime.lastBus = [NSNumber numberWithInt:YES];
                    time.firstBus = [NSNumber numberWithInt:YES];
                    time.sequenceNo = 0;
                    sequence = 0;
                }
                
                BusStop *stop = [[BusStop MR_findByAttribute:@"stop_id" withValue:[item objectForKey:@"id"]] firstObject];
                [stop.timetableSet addObject:time];
                
                previousTime = time;
            } else {
//                NSLog(@"BusTime already exists: %@, %@, %@", busTime.stop_id, busTime.destination, busTime.time);
            }
            sequence++;
            count++;
            
        }
        
    }
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *e) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"coreDataUpdated" object:self];
        [self computeMinorTimetableInformation];
    }];

    NSArray *objects = [BusTime MR_findAll];
    NSLog(@"Time objects in: %i", jsonArray.count);
    NSLog(@"Time objects out: %i", objects.count);
}

- (NSArray *) stopExceptions
{
    NSError *e = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[@"stop_exceptions.json" stringByDeletingPathExtension] ofType:[@"stop_exceptions.json" pathExtension]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    }
    
    return jsonArray;
}

- (void) computeSectionTimes
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //id, name, period, destination, element, fromEnd
    NSArray *stopExceptions = [self stopExceptions];
    
    NSMutableArray *stopExceptionsForWeekdayToSydenham = [NSMutableArray new];
    for (NSDictionary *dictionary in stopExceptions) {
        if ([[dictionary objectForKey:@"period"] isEqualToString:@"weekdays"]) {
            if ([[dictionary objectForKey:@"destination"] isEqualToString:@"sydenham"]) {
                [stopExceptionsForWeekdayToSydenham addObject:dictionary];
            }
        }
    }
                 

    
    // Weekdays to sydenham
    int highestNumOfTimes = 0;
    for (NSDictionary *stop_dictionary in self.reference_stops) {
        int stop_id = [[stop_dictionary objectForKey:@"id"] intValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop_id ==[c] %i AND period ==[c] %@ AND destination ==[c] %@", stop_id, @"weekday", @"sydenham"];
        
        int numOfBusTimes = [[BusTime MR_findAllWithPredicate:predicate inContext:localContext] count];
        
        if (numOfBusTimes > highestNumOfTimes) {
            highestNumOfTimes = numOfBusTimes;
        }
    }

    // For each "column" in the bus timetable, we need to:
    // - Calculate the difference in time between the first reference stop and the next one
    //   - if a stop does not exist (blank entry in PDF timetable), we can ignore it as bus must not be running
    // This whole thing works because a column in the timetable maps to an actual bus proceeding through the network
    // There are gaps in the timetable, which are accounted for by "stop exceptions"
    
    // Timetable to step through
    id timetable[highestNumOfTimes][[self.reference_stops count]];
    
    // For each row
    for (int row = 0; row < [self.reference_stops count]; row++) {
        NSDictionary *stop = (NSDictionary *)[self.reference_stops objectAtIndex:row];
        // For each column
        for (int column = 0; column < highestNumOfTimes; column++) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id ==[c] %i)", [[stop objectForKey:@"id"] longValue]];
            NSPredicate *predicateForEntity = [NSPredicate predicateWithFormat:@"(stop_id ==[c] %i)", [[stop objectForKey:@"id"] longValue]];
            NSArray *exceptionsForStop = [stopExceptionsForWeekdayToSydenham filteredArrayUsingPredicate:predicate];
            for (NSDictionary *exception in exceptionsForStop) {
                if ([[exception objectForKey:@"fromEnd"] isEqualToString:@"NO"] && [[exception objectForKey:@"element"] intValue] == column) {
                    timetable[column][row] = [NSNull null];
                }
                
                if ([[exception objectForKey:@"fromEnd"] isEqualToString:@"YES"] && highestNumOfTimes - 1 - [[exception objectForKey:@"element"] intValue] == column) {
                    timetable[column][row] = [NSNull null];
                }
            }
            
            if (timetable[column][row] == nil) {
                BusStop *referenceBusStop = [[BusStop MR_findAllWithPredicate:predicateForEntity inContext:localContext] firstObject];
                NSString *time = [referenceBusStop.timetableSet objectAtIndex:column];
                timetable[column][row] = time;
            }
            
            NSLog(@"%@", timetable[column][row]);
        }
        NSLog(@"-");
        
    }
    

    
    // Keys for this are a concatenation of the
    NSDictionary *timeDifferences = [NSDictionary new];
    
    for (int x = 0; x < highestNumOfTimes; x++) {
        for (int y = 0; y < [self.reference_stops count]; y++) {
            NSDictionary *stop = (NSDictionary *)[self.reference_stops objectAtIndex:y];
            
            
//            
//            BOOL shouldSkip = NO;
//            for (NSDictionary *dictionary in exceptionsForStop) {
//                if ([[dictionary objectForKey:@"element"] intValue] == x) {
//                    shouldSkip = YES;
//                }
//                
//                if (highestNumOfTimes - [[dictionary objectForKey:@"element"] intValue] == x && [[dictionary objectForKey:@"fromEnd"] isEqualToString:@"YES"]) {
//                    shouldSkip = YES;
//                }
//            }
//            
//            if (shouldSkip == YES) {
//                continue;
//            }
//            
//            // Else proceed to calculate time differences of next times
//            BusStop *referenceBusStop = [[BusStop MR_findAllWithPredicate:predicate inContext:localContext] firstObject];
//            NSString *time = [referenceBusStop.timetableSet objectAtIndex:x];
//            
//            BusStop *nextReferenceBusStop = nil;
//            if (y+1 < [self.reference_stops count]) {
//                NSPredicate *predicateNext = [NSPredicate predicateWithFormat:@"id ==[c] %i", y+1];
//                nextReferenceBusStop = [[BusStop MR_findAllWithPredicate:predicateNext inContext:localContext] firstObject];
//                NSString *nextTime = [nextReferenceBusStop.timetableSet objectAtIndex:x];
//            }

            
        }
    }
    
}

- (void) computeMinorTimetableInformation
{
    [self computeWeekdayMinorTimetables];
}

- (NSMutableArray *)loadReferenceStops:(NSArray *)jsonArray
{
    // Get all the reference stops for the route
    NSMutableArray *ref_stops = [NSMutableArray new];
    for (NSDictionary *item in jsonArray) {
        if ([[item objectForKey:@"ref_stop"] isEqualToString:@"YES"]) {
            [ref_stops addObject:item];
        }
    }
    
    // Keep track of reference stops
    self.reference_stops = ref_stops;
    return ref_stops;
}

- (void) computeWeekdayMinorTimetables
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSError *e = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[@"u1_route.json" stringByDeletingPathExtension] ofType:[@"u1_route.json" pathExtension]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        // Step through the stops for the route. If the stop is a reference stop, set it as so and calculate the
        // total miles between the stop and the next reference stop. Use this milage to calculate the percentage
        // along the route that minor stops lie.
        
        NSMutableArray *ref_stops;
        ref_stops = [self loadReferenceStops:jsonArray];
        [self computeSectionTimes];

        ref_stops = (NSMutableArray *)[[ref_stops reverseObjectEnumerator] allObjects];
        
        NSDictionary *reference_stop = [ref_stops lastObject];
        NSDictionary *next_reference_stop = [ref_stops objectAtIndex:[ref_stops count] - 2];
        
        for (NSDictionary *stop_dictionary in jsonArray) {
            //id,name,ref_stop,ref_stop_id,miles,miles_diff
            if ([stop_dictionary isEqualToDictionary:next_reference_stop]) {
                reference_stop = stop_dictionary;
                [ref_stops removeLastObject];
                
                // Stops accessing index of array when it doesnt exist
                if ([ref_stops count] > 1) {
                    next_reference_stop = [ref_stops objectAtIndex:[ref_stops count] - 2];
                } else {
                    next_reference_stop = reference_stop;
                }
            }
            
            CGFloat milesForReferenceStop = [[reference_stop objectForKey:@"miles"] floatValue];
            CGFloat milesForNextReferenceStop = [[next_reference_stop objectForKey:@"miles"] floatValue];
            CGFloat milesForSection = 0;
            
            if (next_reference_stop == reference_stop) {
                milesForSection = [[[jsonArray lastObject] objectForKey:@"miles"] floatValue] - milesForReferenceStop;
            } else {
                milesForSection = milesForNextReferenceStop - milesForReferenceStop;
            }

            if (milesForSection == 0) {
                NSLog(@"Error, calculated section miles is 0");
            }
            
            CGFloat milesFromReferenceStop = [[stop_dictionary objectForKey:@"miles"] floatValue] - milesForReferenceStop;
            CGFloat percentageAlongSection = milesFromReferenceStop / milesForSection;

            
            
            // Get time total
            // Work out time offset: timetotal * percentageAlongSection
            // Add times to minor bus stop, badum tsh!
        }
    }
}

- (void) computeSaturdayMinorTimetables
{
    
}

- (void) computeSundayMinorTimetables
{
    
}

@end
