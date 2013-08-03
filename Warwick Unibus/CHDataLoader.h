//
//  CHDataLoader.h
//  Warwick Unibus
//
//  Created by Chris Howell on 31/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDataLoader : NSObject


-(id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
-(void)loadData;

+(CHDataLoader*)sharedDataLoader;
+(NSManagedObjectContext*)getManagedObjectContext;
@end
