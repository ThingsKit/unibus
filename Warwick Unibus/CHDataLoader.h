//
//  CHDataLoader.h
//  Warwick Unibus
//
//  Created by Chris Howell on 31/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

@class BusStop;
#import <Foundation/Foundation.h>

@interface CHDataLoader : NSObject


-(id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
-(void)loadData;

+(CHDataLoader*)sharedDataLoader;
+(BusStop *)busStopWithId:(NSNumber *)id;
+(NSManagedObjectContext*)getManagedObjectContext;
@end
