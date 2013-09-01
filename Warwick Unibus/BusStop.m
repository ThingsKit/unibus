#import "BusStop.h"


@interface BusStop ()

// Private interface goes here.

@end

@implementation BusStop
@synthesize _title;

- (CLLocationCoordinate2D)coordinate {
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

- (void) setTitle:(NSString *)t
{
    _title = t;
}

- (NSString *) title
{
    return _title;
}

@end
