//
//  CHMapViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 29/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHMapViewController.h"
#import "CHDataLoader.h"
#import "BusStop.h"
#import "CHTimetableViewController.h"

@interface CHMapViewController ()

@property (nonatomic, weak) IBOutlet ADClusterMapView *mapView;
@property (nonatomic, weak) IBOutlet UIView *timeTableViewPlacement;
@property (nonatomic, strong) CHTimetableViewController *timeTableViewController;

@end

@implementation CHMapViewController

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
    [self.timeTableViewPlacement addSubview:self.timeTableViewController.view];
    [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(0, 0, 0, 0)];
    //self.timeTableViewController.view.frame = CGRectMake(0, 100, self.timeTableViewController.view.frame.size.width, 200);
    self.timeTableViewController.tableView.scrollEnabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    BusStop *stop2 = (BusStop *) stop.cluster.annotation.annotation;
    self.timeTableViewController.titleLabel.text = stop2.name;
}

- (NSInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView
{
    return 20;
}

#pragma mark - UIButton events
-(IBAction)doneButtonPressed:(id)sender
{
    [self.navController setStatusBarWithStyle: UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
