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

typedef enum {
    U1Route,
    U2Route,
    U17Route
} Route;

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
        [self computeMinorTimetableInformationForRoute:U1Route andDestination:@"sydenham"];
//        [self computeMinorTimetableInformationForRoute:U1Route andDestination:@"uni"];
        //[self computeMinorTimetableInformationForRoute:U2Route andDestination:@"sydenham"];
//        [self computeMinorTimetableInformationForRoute:U2Route andDestination:@"uni"];
        //[self computeMinorTimetableInformationForRoute:U17Route andDestination:@"sydenham"];
//        [self computeMinorTimetableInformationForRoute:U17Route andDestination:@"uni"];

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

- (NSArray *) getExceptionsForRoute:(Route)route andDestination:(NSString *)destination
{
    
    NSString *period = @"";
    
    switch (route) {
        case U1Route:
            period = @"weekdays";
            break;
        case U2Route:
            period = @"saturday";
            break;
            
        case U17Route:
            period = @"sunday";
            break;
            
        default:
            break;
    }
    
    //id, name, period, destination, element, fromEnd
    NSArray *stopExceptions = [self stopExceptions];
    
    NSMutableArray *relevantStopExceptions = [NSMutableArray new];
    for (NSDictionary *dictionary in stopExceptions) {
        if ([[dictionary objectForKey:@"period"] isEqualToString:period]) {
            if ([[dictionary objectForKey:@"destination"] isEqualToString:destination]) {
                [relevantStopExceptions addObject:dictionary];
            }
        }
    }
    
    return relevantStopExceptions;
}

- (NSArray *) getReferenceStopsForRoute: (Route) route andDestination:(NSString *) destination
{
    NSArray *allStopsForRoute = nil;
    
    switch (route) {
        case U1Route:
            allStopsForRoute = [self getRouteStopsForRoute:U1Route andDestination:destination];
            break;
        case U2Route:
            allStopsForRoute = [self getRouteStopsForRoute:U2Route andDestination:destination];
            break;
        case U17Route:
            allStopsForRoute = [self getRouteStopsForRoute:U17Route andDestination:destination];
            break;
        default:
            break;
    }

    NSMutableArray *ref_stops = [NSMutableArray new];
    for (NSDictionary *item in allStopsForRoute) {
        if ([[item objectForKey:@"ref_stop"] isEqualToString:@"YES"]) {
            [ref_stops addObject:item];
        }
    }
    
    return ref_stops;
}

- (NSArray *) getRouteStopsForRoute:(Route) route andDestination:(NSString *) destination
{
    NSError *e = nil;
    NSString *filePathString = nil;
    
    switch (route) {
        case U1Route:
            filePathString = [NSString stringWithFormat:@"u1_to_%@.json", destination];
            break;
        case U2Route:
            filePathString = [NSString stringWithFormat:@"u2_to_%@.json", destination];
            break;
        case U17Route:
            filePathString = [NSString stringWithFormat:@"u17_to_%@.json", destination];
            break;
            
        default:
            break;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[filePathString stringByDeletingPathExtension] ofType:[filePathString pathExtension]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    if (!jsonArray) {
        NSLog(@"Error: getRouteStopsForRoute failed to load data");
    }
    return jsonArray;
}

- (NSArray *) getSectionTimesForRoute:(Route) route andDestination:(NSString *) destination
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];

    NSArray *stopExceptions = [self getExceptionsForRoute:route andDestination:destination];
    NSArray *referenceStops = [self getReferenceStopsForRoute:route andDestination:destination];
    
    // Weekdays to sydenham
    int highestNumOfTimes = 0;
    for (NSDictionary *stop_dictionary in referenceStops) {
        int stop_id = [[stop_dictionary objectForKey:@"id"] intValue];
        
        int numOfBusTimes = [[self getStopTimesForStop:[[BusStop MR_findByAttribute:@"stop_id" withValue:[NSNumber numberWithInt:stop_id]] firstObject] onRoute:route andDestination:destination] count];
        
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
    
    NSMutableArray *rowsArray = [NSMutableArray arrayWithCapacity:[referenceStops count]];
    for (int i = 0; i < [referenceStops count]; i++)
    {
        [rowsArray addObject:[NSMutableArray new]];
    }
    
    // For each row barring the last
    for (int row = 0; row < [referenceStops count]; row++) {
        NSDictionary *stop = (NSDictionary *)[referenceStops objectAtIndex:row];
        NSLog(@"%@", [stop objectForKey:@"name"]);
        
        NSPredicate *predicateForEntity = [NSPredicate predicateWithFormat:@"(stop_id ==[c] %i)", [[stop objectForKey:@"id"] longValue]];
        BusStop *referenceBusStop = [[BusStop MR_findAllWithPredicate:predicateForEntity inContext:localContext] firstObject];
        NSMutableArray *times = [NSMutableArray arrayWithArray:[referenceBusStop.timetable array]];
        
        // PROBLEM HERE FOR ST HELENS ROAD, ST HELENS DEST. IS UNI
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(period ==[c] %@ )", @"weekday"];
        times = [NSMutableArray arrayWithArray:[times filteredArrayUsingPredicate:predicate]];
        
        // For each column
        for (int column = 0; column < highestNumOfTimes; column++) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id ==[c] %i)", [[stop objectForKey:@"id"] longValue]];
            
            NSArray *exceptionsForStop = [stopExceptions filteredArrayUsingPredicate:predicate];
            for (NSDictionary *exception in exceptionsForStop) {
                if ([[exception objectForKey:@"fromEnd"] isEqualToString:@"NO"] && [[exception objectForKey:@"element"] intValue] == column) {
                    [[rowsArray objectAtIndex:row] insertObject:[NSNull null] atIndex:column];
                }
                
                if ([[exception objectForKey:@"fromEnd"] isEqualToString:@"YES"] && highestNumOfTimes - 1 - [[exception objectForKey:@"element"] intValue] == column) {
                    [[rowsArray objectAtIndex:row] insertObject:[NSNull null] atIndex:column];
                }
            }
            
            // Check if anything was placed in the array, if not, place the actual time into the array
            if ([[rowsArray objectAtIndex:row] count] == column ) {
                BusTime *time = (BusTime *)[times firstObject];
                
                if (time != nil) {
                    [[rowsArray objectAtIndex:row] insertObject:time.time atIndex:column];
                    [times removeObjectAtIndex:0];
                }
            }
            
             NSLog(@"%@", [[rowsArray objectAtIndex:row] objectAtIndex:column]);
        }
        NSLog(@"-");
    }
    
    // Keys for this are a concatenation of the
    NSMutableArray *timeDifferences = [NSMutableArray new];
    
    for (int x = 0; x < highestNumOfTimes; x++) {
        for (int y = 0; y < [referenceStops count] - 1; y++) {
            
            NSString *time = [[rowsArray objectAtIndex:y] objectAtIndex:x];
            NSString *nextTime = nil;
            if (y <= [referenceStops count] - 2) {
                nextTime = [[rowsArray objectAtIndex:y+1] objectAtIndex:x];
            }
            
            if (time != [NSNull null] && nextTime != [NSNull null]) {
                NSMutableDictionary *timeDifferenceInfo = [NSMutableDictionary new];
                NSNumber *minutesDifference = [NSNumber numberWithInt:[self minutesDifferenceBetween:time and:nextTime]];
                
                [timeDifferenceInfo setObject:[referenceStops objectAtIndex:y] forKey:@"firstReferenceStop"];
                [timeDifferenceInfo setObject:[referenceStops objectAtIndex:y+1] forKey:@"secondReferenceStop"];
                [timeDifferenceInfo setObject:minutesDifference forKey:@"minutesDifference"];
                [timeDifferenceInfo setObject:time forKey:@"time"];
                
                [timeDifferences addObject:timeDifferenceInfo];
            }
        }
    }
    
    return timeDifferences;
}

// Takes two strings like: 2240, 0130, 1715 etc
- (int) minutesDifferenceBetween:(NSString *) timeOne and:(NSString *) timeTwo
{
    NSDate *dateOne = [self dateForTimeString:timeOne];
    NSDate *dateTwo = [self dateForTimeString:timeTwo];
    
    // If datetwo is earlier, i.e. dateOne = 2350, dateTwo = 0010, we must say 20 mins and not be stupid
    // To do this, add a day onto the second date before calculating minutes difference =)
    if ([dateOne earlierDate:dateTwo] == dateTwo) {
        dateTwo = [dateTwo dateByAddingTimeInterval:24 * 60 * 60];
    }
    
    NSTimeInterval secondsBetween = [dateTwo timeIntervalSinceDate:dateOne];
    int minutesDifference = secondsBetween / 60;

    //NSLog(@"%@ -> %@ = %i", timeOne, timeTwo, minutesDifference);
    
    return minutesDifference;
}

- (NSString *) getTimeByAddingMinutes: (int) minutes toDate: (NSDate *) date
{
    NSDate *newDate = [date dateByAddingTimeInterval:minutes * 60];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:newDate];

    NSInteger hoursForDate = [components hour];
    NSInteger minutesForDate = [components minute];
    
    NSString *formattedHours = @"";
    NSString *formattedMinutes = @"";
    
    if (hoursForDate < 10) {
        formattedHours = [NSString stringWithFormat:@"0%d", hoursForDate];
    } else {
        formattedHours = [NSString stringWithFormat:@"%d", hoursForDate];
    }
    
    if (minutesForDate < 10) {
        formattedMinutes = [NSString stringWithFormat:@"0%d", minutesForDate];
    } else {
        formattedMinutes = [NSString stringWithFormat:@"%d", minutesForDate];
    }
    
    
    return [NSString stringWithFormat:@"%@%@", formattedHours, formattedMinutes];
}

- (NSDate *) dateForTimeString: (NSString *) time
{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDate *dateOneDayAhead = [now dateByAddingTimeInterval:oneDay];
    
    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:now];
    //            if ([self.lastMinuteOfDayDate earlierDate:now] == now) {
    //                // If right now is before midnight today
    //                components = [gregorian components:NSUIntegerMax fromDate:dateOneDayAhead];
    //            }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *hours = [numberFormatter numberFromString:[time substringToIndex:2]];
    NSNumber *minutes = [numberFormatter numberFromString:[time substringFromIndex:2]];
    
    [components setHour:hours.intValue];
    [components setMinute:minutes.intValue];
    [components setSecond:0];
    
    NSDate *date = [gregorian dateFromComponents:components];
    
    return date;
}

- (NSArray *) getMinorStopsBetweenReferenceStop: (BusStop *) stopOne andStop: (BusStop *) stopTwo onRoute: (Route) route forDestination: (NSString *) destination
{
    NSMutableArray *minorStops = [NSMutableArray new];
    
    NSArray *allStopsForRoute = [self getRouteStopsForRoute:route andDestination:destination];
    NSArray *referenceStops = [self getReferenceStopsForRoute:route andDestination:destination];
    
    BOOL recordStops = NO;
    for (NSDictionary *dictionary in allStopsForRoute) {
        if ([[dictionary objectForKey:@"id"] isEqualToNumber:stopOne.stop_id]) {
            recordStops = YES;
        }
        if ([dictionary objectForKey:@"id"] == stopTwo.stop_id) {
            recordStops = NO;
        }
        if (recordStops == YES && [[dictionary objectForKey:@"ref_stop"] isEqualToString:@"NO"]) {
            [minorStops addObject:dictionary];
        }
        
        if ((int)[dictionary objectForKey:@"id"] == 47) {
            
        }
    }
    
    return [minorStops copy];
}

- (void) computeMinorTimetableInformationForRoute:(Route) route andDestination: (NSString *) destination
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread ];
    
    NSArray *sectionTimes = [self getSectionTimesForRoute:route andDestination:destination];
    
    int i = 0;
    NSDictionary *stopSectionPercentages = [self getPercentagesForRoute:route andDestination:destination];
    
    int sequence = 0;
    for (NSDictionary *sectionInfo in sectionTimes) {
        NSDictionary *firstReferenceStop = [sectionInfo objectForKey:@"firstReferenceStop"];
        NSDictionary *secondReferenceStop = [sectionInfo objectForKey:@"secondReferenceStop"];
        NSNumber *minutesDifference = [sectionInfo objectForKey:@"minutesDifference"];
        NSString *time = [sectionInfo objectForKey:@"time"];
        
        BusStop *firstStop = [[BusStop MR_findByAttribute:@"stop_id" withValue:[firstReferenceStop objectForKey:@"id"]] firstObject];
        BusStop *secondStop = [[BusStop MR_findByAttribute:@"stop_id" withValue:[secondReferenceStop objectForKey:@"id"]] firstObject];
        
        NSArray *minorStops = [self getMinorStopsBetweenReferenceStop:firstStop andStop:secondStop onRoute:route forDestination:destination];
        
        
        for (NSDictionary *minorStopDictionary in minorStops) {
            BusStop *minorStop = [[BusStop MR_findByAttribute:@"stop_id" withValue:[minorStopDictionary objectForKey:@"id"]] firstObject];;
            NSArray *stopTimes = [self getStopTimesForStop:firstStop onRoute:route andDestination:destination];
            
            float percentage = [[stopSectionPercentages objectForKey:[minorStopDictionary objectForKey:@"id"]] floatValue];
            int minutesToAdd = minutesDifference.intValue * percentage;
            
            NSString *newTimeString = [self getTimeByAddingMinutes:minutesToAdd toDate:[self dateForTimeString:time]];
            if ([newTimeString length] < 4) {
                //newTimeString = [NSString stringWithFormat:@"0%@", newTimeString];
            }
            
            
            NSString *period = @"";
            NSString *number = @"";
            switch (route) {
                case U1Route:
                    period = @"weekday";
                    number = @"u1";
                    break;
                case U2Route:
                    period = @"saturdays";
                    number = @"u2";
                    break;
                case U17Route:
                    period = @"sundays";
                    number = @"u17";
                    break;
                    
                default:
                    break;
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop_id ==[c] %@ AND time LIKE[c] %@ AND destination LIKE[c] %@ AND period LIKE[c] %@ AND number LIKE[c] %@", minorStop.stop_id, newTimeString, destination, period, number];
            BusTime *busTime = [BusTime MR_findFirstWithPredicate:predicate inContext:localContext];
            //NSLog(@"%@",predicate);
            if (!busTime) {
                
                BusTime *newTime = [BusTime MR_createInContext:localContext];
                
                newTime.time = newTimeString;
                newTime.stop_id = minorStop.stop_id;
                newTime.destination = destination;
                newTime.sequenceNo = [NSNumber numberWithInt:sequence];
                newTime.period = period;
                newTime.number = number;

                [[minorStop timetableSet] addObject:newTime];
            }
            NSLog(@"%@ + %i -> %@ for stop %@", time, minutesToAdd, newTimeString, minorStop.name);
            
        }
        sequence++;
        
    }
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        
    }];
    
    //[self computeWeekdayMinorTimetables];
}


- (NSArray *) getStopTimesForStop: (BusStop *) stop onRoute: (Route) route andDestination: (NSString *) destination
{
    NSArray *stopTimes = [NSArray new];
    
    NSString *period = @"";
    switch (route) {
        case U1Route:
            period = @"weekday";
            break;
            
        case U2Route:
            period = @"saturdays";
            break;
            
        case U17Route:
            period = @"sundays";
            break;
            
        default:
            break;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop_id ==[c] %@ AND period ==[c] %@ AND destination ==[c] %@", stop.stop_id, period, destination];
    stopTimes = [stop.timetable array];
    stopTimes = [stopTimes filteredArrayUsingPredicate:predicate];
    
    return stopTimes;
}

- (NSDictionary *) getPercentagesForRoute: (Route) route andDestination: (NSString *) destination
{
    NSMutableDictionary *percentageDifferences = [NSMutableDictionary new];
    
    NSError *e = nil;
    NSArray *jsonArray = [self getRouteStopsForRoute:route andDestination:destination];
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        // Step through the stops for the route. If the stop is a reference stop, set it as so and calculate the
        // total miles between the stop and the next reference stop. Use this milage to calculate the percentage
        // along the route that minor stops lie.
        
        NSMutableArray *ref_stops;
        ref_stops = [[self getReferenceStopsForRoute:route andDestination:destination] mutableCopy];
        //NSDictionary *sectionTimes = [self getSectionTimesForRoute:U1Route andDestination:@"sydenham"];

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
            
            [percentageDifferences setObject:[NSNumber numberWithFloat:percentageAlongSection] forKey:[stop_dictionary objectForKey:@"id"]];

            // Calculate time between refStop and nextRefStop, for this route and
            
            
            // Get time total
            // Work out time offset: timetotal * percentageAlongSection
            // Add times to minor bus stop, badum tsh!
        }
    }
    
    return percentageDifferences;
}

- (void) computeSaturdayMinorTimetables
{
    
}

- (void) computeSundayMinorTimetables
{
    
}

@end
