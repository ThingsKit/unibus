#import "BusStop.h"


@interface BusStop ()

// Private interface goes here.

@end


@implementation BusStop

- (CLLocationCoordinate2D)coordinate {
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

@end
