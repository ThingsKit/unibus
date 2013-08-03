// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusStop.m instead.

#import "_BusStop.h"

const struct BusStopAttributes BusStopAttributes = {
	.latitude = @"latitude",
	.longitude = @"longitude",
	.name = @"name",
	.stop_id = @"stop_id",
};

const struct BusStopRelationships BusStopRelationships = {
	.timetable = @"timetable",
};

const struct BusStopFetchedProperties BusStopFetchedProperties = {
};

@implementation BusStopID
@end

@implementation _BusStop

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BusStop" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BusStop";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BusStop" inManagedObjectContext:moc_];
}

- (BusStopID*)objectID {
	return (BusStopID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
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




@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






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





@dynamic timetable;

	
- (NSMutableOrderedSet*)timetableSet {
	[self willAccessValueForKey:@"timetable"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"timetable"];
  
	[self didAccessValueForKey:@"timetable"];
	return result;
}
	






@end
