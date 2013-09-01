#import "_BusStop.h"
#import <MapKit/MapKit.h>

@interface BusStop : _BusStop <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
}

@property (nonatomic, copy) NSString *_title;

- (void) setTitle:(NSString *)t;
@end
