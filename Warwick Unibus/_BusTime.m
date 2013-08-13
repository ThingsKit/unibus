// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusTime.m instead.

#import "_BusTime.h"

const struct BusTimeAttributes BusTimeAttributes = {
	.destination = @"destination",
	.number = @"number",
	.period = @"period",
	.stop_id = @"stop_id",
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
	
	if ([key isEqualToString:@"stop_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stop_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic destination;






@dynamic number;






@dynamic period;






@dynamic stop_id;



- (int16_t)stop_idValue {
	NSNumber *result = [self stop_id];
	return [result shortValue];
}

- (void)setStop_idValue:(int16_t)value_ {
	[self setStop_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStop_idValue {
	NSNumber *result = [self primitiveStop_id];
	return [result shortValue];
}

- (void)setPrimitiveStop_idValue:(int16_t)value_ {
	[self setPrimitiveStop_id:[NSNumber numberWithShort:value_]];
}





@dynamic time;






@dynamic relationship;

	






@end
