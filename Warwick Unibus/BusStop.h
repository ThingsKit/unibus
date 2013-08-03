#import "_BusStop.h"
#import <MapKit/MapKit.h>

@interface BusStop : _BusStop <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}
@end
