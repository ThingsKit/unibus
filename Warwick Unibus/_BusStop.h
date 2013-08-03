// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusStop.h instead.

#import <CoreData/CoreData.h>


extern const struct BusStopAttributes {
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *stop_id;
} BusStopAttributes;

extern const struct BusStopRelationships {
	__unsafe_unretained NSString *timetable;
} BusStopRelationships;

extern const struct BusStopFetchedProperties {
} BusStopFetchedProperties;

@class BusTime;






@interface BusStopID : NSManagedObjectID {}
@end

@interface _BusStop : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BusStopID*)objectID;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* stop_id;



@property int16_t stop_idValue;
- (int16_t)stop_idValue;
- (void)setStop_idValue:(int16_t)value_;

//- (BOOL)validateStop_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *timetable;

- (NSMutableOrderedSet*)timetableSet;





@end

@interface _BusStop (CoreDataGeneratedAccessors)

- (void)addTimetable:(NSOrderedSet*)value_;
- (void)removeTimetable:(NSOrderedSet*)value_;
- (void)addTimetableObject:(BusTime*)value_;
- (void)removeTimetableObject:(BusTime*)value_;

@end

@interface _BusStop (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveStop_id;
- (void)setPrimitiveStop_id:(NSNumber*)value;

- (int16_t)primitiveStop_idValue;
- (void)setPrimitiveStop_idValue:(int16_t)value_;





- (NSMutableOrderedSet*)primitiveTimetable;
- (void)setPrimitiveTimetable:(NSMutableOrderedSet*)value;


@end
