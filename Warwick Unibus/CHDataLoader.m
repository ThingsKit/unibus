//
//  CHDataLoader.m
//  Warwick Unibus
//
//  Created by Chris Howell on 31/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHDataLoader.h"
#import "BusStop.h"

@interface CHDataLoader()
@end

@implementation CHDataLoader

static CHDataLoader *sharedDataLoader = nil;    // static instance variable
static NSManagedObjectContext *managedObjectContext;


-(id)initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    self = [super init];
    if(self) {
        managedObjectContext = moc;
    }
    return self;
}

+(CHDataLoader*)sharedDataLoader
{
    if (sharedDataLoader == nil) {
        sharedDataLoader = [[super alloc] init];
    }
    return sharedDataLoader;
}

+(NSManagedObjectContext*)getManagedObjectContext
{
    return managedObjectContext;
}

-(void)loadData
{
    [self loadBusData];
}

-(void)loadBusData
{
    NSError *e = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[@"busstops.json" stringByDeletingPathExtension] ofType:[@"busstops.json" pathExtension]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        for(NSDictionary *item in jsonArray) {
            NSLog(@"%@", item);
            
            // Check if bus stop already exists
            NSFetchRequest *existentialCheck = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"BusStop" inManagedObjectContext:managedObjectContext];
            [existentialCheck setEntity:entity];
            [existentialCheck setPredicate:[NSPredicate predicateWithFormat:@"stop_id=%@", [item objectForKey:@"id"]]];
            
            NSError *error;
            NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:existentialCheck error:&error];
            
            BusStop *busStop = nil;
            
            busStop = [fetchedObjects lastObject];
            if (!busStop) {
                // create
                busStop = [NSEntityDescription
                               insertNewObjectForEntityForName:@"BusStop"
                               inManagedObjectContext:managedObjectContext];
                
                busStop.stop_id = [item objectForKey:@"id"];
                busStop.name = [item objectForKey:@"name"];
                busStop.latitude = [NSNumber numberWithDouble:[[item objectForKey:@"latitude"] doubleValue]];
                busStop.longitude = [NSNumber numberWithDouble:[[item objectForKey:@"longitude"] doubleValue]];
            }
        
        }
        NSError *saveError = nil;
        [managedObjectContext save:&saveError];  //saves the context to disk
        
    }
//    NSError *error2 = nil;
//
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BusStop"
//                                              inManagedObjectContext:managedObjectContext];
//    [fetchRequest setEntity:entity];
//    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error2];
//    for (BusStop *info in fetchedObjects) {
//        NSLog(@"id: %@", info.stop_id);
//        NSLog(@"Zip: %@", info.name);
//    }
    
}

-(void)loadTimetableData
{
    
}

@end
