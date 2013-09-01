// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusTime.m instead.

#import "_BusTime.h"

const struct BusTimeAttributes BusTimeAttributes = {
	.destination = @"destination",
	.firstBus = @"firstBus",
	.lastBus = @"lastBus",
	.number = @"number",
	.period = @"period",
	.sequenceNo = @"sequenceNo",
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
	
	if ([key isEqualToString:@"firstBusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"firstBus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lastBusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastBus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sequenceNoValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sequenceNo"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stop_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stop_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic destination;






@dynamic firstBus;



- (BOOL)firstBusValue {
	NSNumber *result = [self firstBus];
	return [result boolValue];
}

- (void)setFirstBusValue:(BOOL)value_ {
	[self setFirstBus:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFirstBusValue {
	NSNumber *result = [self primitiveFirstBus];
	return [result boolValue];
}

- (void)setPrimitiveFirstBusValue:(BOOL)value_ {
	[self setPrimitiveFirstBus:[NSNumber numberWithBool:value_]];
}





@dynamic lastBus;



- (BOOL)lastBusValue {
	NSNumber *result = [self lastBus];
	return [result boolValue];
}

- (void)setLastBusValue:(BOOL)value_ {
	[self setLastBus:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLastBusValue {
	NSNumber *result = [self primitiveLastBus];
	return [result boolValue];
}

- (void)setPrimitiveLastBusValue:(BOOL)value_ {
	[self setPrimitiveLastBus:[NSNumber numberWithBool:value_]];
}





@dynamic number;






@dynamic period;






@dynamic sequenceNo;



- (int16_t)sequenceNoValue {
	NSNumber *result = [self sequenceNo];
	return [result shortValue];
}

- (void)setSequenceNoValue:(int16_t)value_ {
	[self setSequenceNo:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSequenceNoValue {
	NSNumber *result = [self primitiveSequenceNo];
	return [result shortValue];
}

- (void)setPrimitiveSequenceNoValue:(int16_t)value_ {
	[self setPrimitiveSequenceNo:[NSNumber numberWithShort:value_]];
}





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
