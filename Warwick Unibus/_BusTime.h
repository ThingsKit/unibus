// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusTime.h instead.

#import <CoreData/CoreData.h>


extern const struct BusTimeAttributes {
	__unsafe_unretained NSString *destination;
	__unsafe_unretained NSString *firstBus;
	__unsafe_unretained NSString *lastBus;
	__unsafe_unretained NSString *number;
	__unsafe_unretained NSString *period;
	__unsafe_unretained NSString *sequenceNo;
	__unsafe_unretained NSString *stop_id;
	__unsafe_unretained NSString *time;
} BusTimeAttributes;

extern const struct BusTimeRelationships {
	__unsafe_unretained NSString *relationship;
} BusTimeRelationships;

extern const struct BusTimeFetchedProperties {
} BusTimeFetchedProperties;

@class BusStop;










@interface BusTimeID : NSManagedObjectID {}
@end

@interface _BusTime : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BusTimeID*)objectID;





@property (nonatomic, strong) NSString* destination;



//- (BOOL)validateDestination:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* firstBus;



@property BOOL firstBusValue;
- (BOOL)firstBusValue;
- (void)setFirstBusValue:(BOOL)value_;

//- (BOOL)validateFirstBus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* lastBus;



@property BOOL lastBusValue;
- (BOOL)lastBusValue;
- (void)setLastBusValue:(BOOL)value_;

//- (BOOL)validateLastBus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* number;



//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* period;



//- (BOOL)validatePeriod:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sequenceNo;



@property int16_t sequenceNoValue;
- (int16_t)sequenceNoValue;
- (void)setSequenceNoValue:(int16_t)value_;

//- (BOOL)validateSequenceNo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* stop_id;



@property int16_t stop_idValue;
- (int16_t)stop_idValue;
- (void)setStop_idValue:(int16_t)value_;

//- (BOOL)validateStop_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* time;



//- (BOOL)validateTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) BusStop *relationship;

//- (BOOL)validateRelationship:(id*)value_ error:(NSError**)error_;





@end

@interface _BusTime (CoreDataGeneratedAccessors)

@end

@interface _BusTime (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDestination;
- (void)setPrimitiveDestination:(NSString*)value;




- (NSNumber*)primitiveFirstBus;
- (void)setPrimitiveFirstBus:(NSNumber*)value;

- (BOOL)primitiveFirstBusValue;
- (void)setPrimitiveFirstBusValue:(BOOL)value_;




- (NSNumber*)primitiveLastBus;
- (void)setPrimitiveLastBus:(NSNumber*)value;

- (BOOL)primitiveLastBusValue;
- (void)setPrimitiveLastBusValue:(BOOL)value_;




- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;




- (NSString*)primitivePeriod;
- (void)setPrimitivePeriod:(NSString*)value;




- (NSNumber*)primitiveSequenceNo;
- (void)setPrimitiveSequenceNo:(NSNumber*)value;

- (int16_t)primitiveSequenceNoValue;
- (void)setPrimitiveSequenceNoValue:(int16_t)value_;




- (NSNumber*)primitiveStop_id;
- (void)setPrimitiveStop_id:(NSNumber*)value;

- (int16_t)primitiveStop_idValue;
- (void)setPrimitiveStop_idValue:(int16_t)value_;




- (NSString*)primitiveTime;
- (void)setPrimitiveTime:(NSString*)value;





- (BusStop*)primitiveRelationship;
- (void)setPrimitiveRelationship:(BusStop*)value;


@end
