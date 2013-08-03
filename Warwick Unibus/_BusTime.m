// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusTime.m instead.

#import "_BusTime.h"

const struct BusTimeAttributes BusTimeAttributes = {
	.number = @"number",
	.time = @"time",
};

const struct BusTimeRelationships BusTimeRelationships = {
	.relationship = @"relationship",
};

const struct BusTimeFetchedProperties BusTimeFetchedProperties = {
};

@implementation BusTimeID
@end

@implementation _BusTime

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BusTime" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BusTime";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BusTime" inManagedObjectContext:moc_];
}

- (BusTimeID*)objectID {
	return (BusTimeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic number;






@dynamic time;






@dynamic relationship;

	






@end
