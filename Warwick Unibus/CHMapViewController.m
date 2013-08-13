//
//  CHMapViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 29/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

typedef enum {
    kU1BusRoute,
    kU2BusRoute,
    kU17BusRoute
} BusRoute;

#import "CHMapViewController.h"
#import "CHDataLoader.h"
#import "BusStop.h"
#import "CHTimetableViewController.h"

@interface CHMapViewController ()

@property (nonatomic, weak) IBOutlet ADClusterMapView *mapView;
@property (nonatomic, strong) CHTimetableViewController *timeTableViewController;

@property (nonatomic, weak) IBOutlet UIView *topBar;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic, weak) IBOutlet UIButton *u1Button;
@property (nonatomic, weak) IBOutlet UIButton *u2Button;
@property (nonatomic, weak) IBOutlet UIButton *u17Button;
@property (nonatomic, weak) IBOutlet UIImageView *selectedImage;

@property (nonatomic, assign) BusRoute routeSelected;
@property (nonatomic, assign) CGFloat currentSelectedImageOffset;

@property (nonatomic, weak) IBOutlet UIView *notifView;
@property (nonatomic, weak) IBOutlet UILabel *notifLabel;
@property (nonatomic, weak) IBOutlet UIImageView *notifImageView;

@end

static CHMapViewController *sharedMap;

@implementation CHMapViewController

+ (CHMapViewController *) sharedMap {
    if (sharedMap == nil) {
        sharedMap = [[super alloc] init];
        sharedMap.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }

    return sharedMap;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.335127,-1.546721);
     MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(location, 15000, 15000)];
    
    [self.mapView setRegion:adjustedRegion animated:YES];
    [self loadAnnotations];
    
    // Setup timetable view
    self.timeTableViewController = [[CHTimetableViewController alloc] init];
    [self.view addSubview:self.timeTableViewController.view];
    
    
    [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(414, 0, 0, 0)];
    self.timeTableViewController.view.frame = CGRectMake(0, 200, self.timeTableViewController.view.frame.size.width, 568);
    [self.timeTableViewController.tableView setViewToReturnTo:self.view];
    self.timeTableViewController.tableView.startOffset = 414;
    self.timeTableViewController.view.hidden = YES;
    self.timeTableViewController.delegate = self;
    
    // Set selected bus route
    if (!self.routeSelected) {
        self.routeSelected = kU1BusRoute;
    }
    
    [self.view addSubview:self.notifView];
    //self.notifView.frame = CGRectMake(0, 0, self.notifView.frame.size.width, self.notifView.frame.size.width);
    [self.view bringSubviewToFront:self.topBar];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CHTimetableViewControllerDelegate
- (void) userDidFavouriteStop
{
    self.notifLabel.text = @"Added favourite bus stop";
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.notifView.frame = CGRectMake(0, 90, self.notifView.frame.size.width, self.notifView.frame.size.width);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:2.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.notifView.frame = CGRectMake(0, 0, self.notifView.frame.size.width, self.notifView.frame.size.width);
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
}

- (void) userDidUnfavouriteStop
{
    self.notifLabel.text = @"Removed favourite bus stop";
    //self.notifImageView setImage:[UIImage imageNamed:@""];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.notifView.frame = CGRectMake(0, 90, self.notifView.frame.size.width, self.notifView.frame.size.width);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:2.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.notifView.frame = CGRectMake(0, 0, self.notifView.frame.size.width, self.notifView.frame.size.width);
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
}

-(void) scrollViewDidScrollBy:(CGFloat) offset
{
    
}

#pragma mark - Setters
- (void) setRouteSelected:(BusRoute)routeSelected
{
    _routeSelected = routeSelected;
    // Animate to the button
    
    CGFloat offset = 11;
    switch (routeSelected) {
        case kU1BusRoute:
            offset = 11;
            break;
        case kU2BusRoute:
            offset = 116;
            break;
        case kU17BusRoute:
            offset = 220;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.selectedImage.frame = CGRectMake(offset, self.selectedImage.frame.origin.y, self.selectedImage.frame.size.width, self.selectedImage.frame.size.height);
                     }
                     completion:^(BOOL finished){

                     }];

  
}

-(void)loadAnnotations
{
    NSManagedObjectContext *moc = [CHDataLoader getManagedObjectContext];
    NSFetchRequest *busStopRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *busStopDescription = [NSEntityDescription entityForName:@"BusStop" inManagedObjectContext:moc];
    [busStopRequest setEntity:busStopDescription];
    
    NSError *error;
    NSArray *fetchedBusStops = [moc executeFetchRequest:busStopRequest error:&error];
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (BusStop *busStop in fetchedBusStops) {
        MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:busStop reuseIdentifier:@"busStopPin"];
        pin.image = [UIImage imageNamed:@"bussign.png"];
        
        [annotations addObject:busStop];
    }
    
    [self.mapView setAnnotations: annotations];
    
    self.mapView.showsUserLocation = YES;
}
      
#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation){
        return nil; //default to blue dot
    }
    
    NSString *reuseId = @"busStopPin";
    MKAnnotationView *annView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (annView == nil)
    {
        annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        annView.image = [UIImage imageNamed:@"bussign.png"];
        annView.centerOffset = CGPointMake(10, -29);

     
        
    }
    else
    {
        //update the annotation property if view is being re-used...
        annView.annotation = annotation;
    }
    
    return annView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    ADClusterAnnotation *stop = view.annotation;
    NSLog(@"%@", stop.cluster.annotation.annotation);
    BusStop *busStop = (BusStop *) stop.cluster.annotation.annotation;
    self.timeTableViewController.busStop = busStop;
    
    self.timeTableViewController.view.hidden = NO;
    
    if (busStop != nil) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.timeTableViewController.view.frame = CGRectMake(0, 0, self.timeTableViewController.view.frame.size.width, 568);
                         }
                         completion:^(BOOL finished){
                             
                         }];

    }

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.timeTableViewController.view.frame = CGRectMake(0, 200, self.timeTableViewController.view.frame.size.width, 568);
                     }
                     completion:^(BOOL finished){
                         self.timeTableViewController.view.hidden = YES;
                     }];
}

- (NSInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView
{
    return 25;
}

#pragma mark - UIButton events
-(IBAction)doneButtonPressed:(id)sender
{
    //[self.navController setStatusBarWithStyle: UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)segmentButtonPressed:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
            self.routeSelected = kU1BusRoute;
            break;
        case 1:
            self.routeSelected = kU2BusRoute;
            break;
        case 2:
            self.routeSelected = kU17BusRoute;
            break;
        default:
            break;
    }
}
@end
