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
#import "CoreData+MagicalRecord.h"
#import "BusStop.h"
#import "BusTime.h"
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
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            //Load 3.5 inch xib
            [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(326, 0, 0, 0)];
        }
        if(result.height == 568)
        {
            //Load 4 inch xib
            [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(414, 0, 0, 0)];
        }
    }
    
    self.timeTableViewController.view.frame = CGRectMake(0, 200, self.timeTableViewController.view.frame.size.width, 568);
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
    self.notifLabel.frame = CGRectMake(74, self.notifLabel.frame.origin.y, self.notifLabel.frame.size.width, self.notifLabel.frame.size.height);
    self.notifImageView.image = [UIImage imageNamed:@"plus.png"];
    self.notifImageView.frame = CGRectMake(21, self.notifImageView.frame.origin.y, self.notifImageView.frame.size.width, self.notifImageView.frame.size.height);
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
    self.notifLabel.frame = CGRectMake(64, self.notifLabel.frame.origin.y, self.notifLabel.frame.size.width, self.notifLabel.frame.size.height);
    self.notifImageView.image = [UIImage imageNamed:@"minus.png"];
    self.notifImageView.frame = CGRectMake(11, self.notifImageView.frame.origin.y, self.notifImageView.frame.size.width, self.notifImageView.frame.size.height);
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
    
    //[self loadAnnotationsForRoute:routeSelected];
}

-(void)loadAnnotations
{
    [self loadAnnotationsForRoute:kU1BusRoute];
}

-(void)loadAnnotationsForRoute:(BusRoute) route
{
//    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSArray *busStops = [BusStop MR_findAll];
    
    NSString *queryString = @"";
    switch (route) {
        case kU1BusRoute:
            queryString = @"u1";
            break;
        case kU2BusRoute:
            queryString = @"u2";
            break;
        case kU17BusRoute:
            queryString = @"u17";
            break;
        default:
            break;
    }
    
    NSMutableArray *busStopsMatched = [NSMutableArray new];
    for (BusStop *stop in busStops) {
        for (BusTime *time in [[stop timetableSet] array]) {
            if ([time.number isEqualToString:queryString]) {
                [busStopsMatched addObject:stop];
                break;
            }
        }
    }
    
    busStopsMatched = busStops;
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (BusStop *busStop in busStopsMatched) {
        busStop.title = busStop.name;
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
        annView.canShowCallout = NO;
    }
    else
    {
        //update the annotation property if view is being re-used...
        annView.annotation = annotation;
        annView.canShowCallout = NO;
    }
    
    return annView;
}

- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id <MKAnnotation>)annotation
{
    NSString *reuseId = @"busStopPin";
    MKAnnotationView *annView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (annView == nil)
    {
        annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        annView.image = [UIImage imageNamed:@"bussign.png"];
        annView.centerOffset = CGPointMake(10, -29);
        annView.canShowCallout = YES;
    }
    else
    {
        //update the annotation property if view is being re-used...
        annView.annotation = annotation;
        annView.canShowCallout = YES;

    }
    
    return annView;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    ADClusterAnnotation *stop = view.annotation;
    BusStop *busStop = (BusStop *) stop.cluster.annotation.annotation;
    
    self.timeTableViewController.view.hidden = NO;
    
    if (busStop != nil) {
        
        // This is messy =(
        if (self.timeTableViewController.view.frame.origin.y == 0 ) {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.timeTableViewController.view.frame = CGRectMake(0, 200 - self.timeTableViewController.tableView.contentOffset.y, self.timeTableViewController.view.frame.size.width, 568);
                             }
                             completion:^(BOOL finished){
                                 self.timeTableViewController.busStop = busStop;
                                 if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                                 {
                                     CGSize result = [[UIScreen mainScreen] bounds].size;
                                     if(result.height == 480)
                                     {
                                         //Load 3.5 inch xib
                                         [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(326, 0, 0, 0)];
                                     }
                                     if(result.height == 568)
                                     {
                                         //Load 4 inch xib
                                         [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(414, 0, 0, 0)];
                                     }
                                 }
                                 
                                 [UIView animateWithDuration:0.3
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                                                      {
                                                          CGSize result = [[UIScreen mainScreen] bounds].size;
                                                          if(result.height == 480)
                                                          {
                                                              //Load 3.5 inch xib
                                                              self.timeTableViewController.view.frame = CGRectMake(0, 0, self.timeTableViewController.view.frame.size.width, 480);
                                                          }
                                                          if(result.height == 568)
                                                          {
                                                              //Load 4 inch xib
                                                              self.timeTableViewController.view.frame = CGRectMake(0, 0, self.timeTableViewController.view.frame.size.width, 568);
                                                          }
                                                      }
                                                      
                                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                  }];
                             }];
        } else {
            self.timeTableViewController.busStop = busStop;

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                                 {
                                     CGSize result = [[UIScreen mainScreen] bounds].size;
                                     if(result.height == 480)
                                     {
                                         //Load 3.5 inch xib
                                         self.timeTableViewController.view.frame = CGRectMake(0, 0, self.timeTableViewController.view.frame.size.width, 480);
                                     }
                                     if(result.height == 568)
                                     {
                                         //Load 4 inch xib
                                         self.timeTableViewController.view.frame = CGRectMake(0, 0, self.timeTableViewController.view.frame.size.width, 568);
                                     }
                                 }

                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
    }
}

- (BOOL)shouldShowSubtitleForClusterAnnotationsInMapView:(ADClusterMapView *)mapView
{
    return YES;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        self.timeTableViewController.view.frame = CGRectMake(0, 200 - self.timeTableViewController.tableView.contentOffset.y, self.timeTableViewController.view.frame.size.width, 568);
                     }
                     completion:^(BOOL finished){
                         self.timeTableViewController.view.hidden = YES;
                     }];
}

- (NSInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView
{
    return 25;
}

- (NSString *)clusterTitleForMapView:(ADClusterMapView *)mapView
{
    return @"%d bus stops";
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
