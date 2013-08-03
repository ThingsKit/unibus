// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BusTime.h instead.

#import <CoreData/CoreData.h>


extern const struct BusTimeAttributes {
	__unsafe_unretained NSString *number;
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





@property (nonatomic, strong) NSString* number;



//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* time;



//- (BOOL)validateTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) BusStop *relationship;

//- (BOOL)validateRelationship:(id*)value_ error:(NSError**)error_;





@end

@interface _BusTime (CoreDataGeneratedAccessors)

@end

@interface _BusTime (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;




- (NSDate*)primitiveTime;
- (void)setPrimitiveTime:(NSDate*)value;





- (BusStop*)primitiveRelationship;
- (void)setPrimitiveRelationship:(BusStop*)value;


@end
