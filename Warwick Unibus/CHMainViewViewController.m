//
//  CHMainViewViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 24/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHMainViewViewController.h"
#import "UIColor+AppColors.h"
#import "CHTimetableCell.h"
#import "CHBusStopViewController.h"
#import "CHMapViewController.h"
#import <iAd/iAd.h>
#import "GPUImage.h"
#import <Parse/Parse.h>


@interface CHMainViewViewController ()

@property (nonatomic, strong) IBOutlet UIButton *mapButton;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet NSArray *views;
@property (nonatomic, strong) IBOutlet NSArray *viewControllers;

@property (nonatomic, strong) IBOutlet PFImageView *bgImage;

@property (nonatomic, strong) IBOutlet CHMapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet UIView *mapView;

@property (nonatomic, assign) BOOL hasJustDeleted;
@property (nonatomic, strong) NSNumber *idToDelete;

@end

NSInteger pageNum;
BOOL isScrolling;

@implementation CHMainViewViewController

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
    
    self.mapViewController = [[CHMapViewController alloc] init];
    [self loadData];
    
    [self setupScrollView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification
    
                                               object:nil];
    
    [PFImageView class];
    //PFImageView *creature = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"main_image.jpeg" ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    
    self.bgImage.image = image;

    if (self.bgImage.image == nil) {
        self.bgImage.image = [UIImage imageNamed:@"ImgBlur.png"]; // placeholder image
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"name" equalTo:@"Andrew"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            self.bgImage.file = (PFFile *) [object objectForKey:@"picture"];
            [self.bgImage loadInBackground:^( UIImage *image , NSError *error ){
                
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *jpegFilePath = [NSString stringWithFormat:@"%@/main_image.jpeg",docDir];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                [data2 writeToFile:jpegFilePath atomically:YES];
            }];
            
        } else {
            NSLog(@"Error querying for image: %@", error);
        }
    }];
    
//    UIInterpolatingMotionEffect *mx3 = [[UIInterpolatingMotionEffect alloc]
//                                        initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    mx3.maximumRelativeValue = @20.0;
//    mx3.minimumRelativeValue = @-20.0;
//    
//    UIInterpolatingMotionEffect *mx4 = [[UIInterpolatingMotionEffect alloc]
//                                        initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    mx4.maximumRelativeValue = @20.0;
//    mx4.minimumRelativeValue = @-20.0;
//    
//    [self.bgImage addMotionEffect:mx3];
//    [self.bgImage addMotionEffect:mx4];
    
    isScrolling = NO;
}

- (void) attemptImageDownload
{
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"name" equalTo:@"Andrew"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            self.bgImage.file = (PFFile *) [object objectForKey:@"picture"];
            [self.bgImage loadInBackground:^( UIImage *image , NSError *error ){
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *jpegFilePath = [NSString stringWithFormat:@"%@/main_image.jpeg",docDir];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                [data2 writeToFile:jpegFilePath atomically:YES];
            }];
        }
    }];
}

- (void) loadData
{
    for (UIView *view in self.views) {
        [view removeFromSuperview];
    }
    
    self.viewControllers = nil;
    
    // Create bus stops
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *ids = [prefs arrayForKey:@"stops"];
    if (ids == nil) {
        NSLog(@"Error loading user preferences");
    }
    
    NSMutableArray *newControllers = [[NSMutableArray alloc] init];
    NSMutableArray *newViews = [[NSMutableArray alloc] init];
    for (NSNumber *number in ids) {
        NSLog(@"adding id: %i", number.intValue);
        CHBusStopViewController *busStopViewController = [[CHBusStopViewController alloc] initWithBusStopId:number];
        if (ids.count == 1) {
            busStopViewController.hideRemoveButton = YES;
        } else {
            busStopViewController.hideRemoveButton  = NO;
        }
        [newControllers addObject:busStopViewController];
        [newViews addObject:busStopViewController.view];
    }
    self.viewControllers = newControllers;
    self.views = newViews;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) defaultsChanged:(NSNotification *) notification
{
    [self loadData];
    [self setupScrollView];
}

#pragma mark - UIButton events
-(IBAction)mapButtonWasPressed:(id)sender
{
    //self.mapViewController.navController = self.navigationController;
   // self.mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            //Load 3.5 inch xib
            if (self.mapViewController == nil) {
                self.mapViewController = [[CHMapViewController alloc] initWithNibName:@"CHMapViewController_3.5" bundle:[NSBundle mainBundle]];
            }

        }
        if(result.height == 568)
        {
            //Load 4 inch xib
            if (self.mapViewController == nil) {
                self.mapViewController = [[CHMapViewController alloc] initWithNibName:@"CHMapViewController_4" bundle:[NSBundle mainBundle]];
            }
        }
    }
    
    self.mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    [self.navigationController presentViewController:self.mapViewController animated:YES completion:nil];
    [self.navigationController setStatusBarWithStyle:UIStatusBarStyleLightContent];
}

#pragma mark - CHBusStopViewControllerDelegate
-(void)CHBusStopTableviewDidMoveBy:(float)offset
{
    for (CHBusStopViewController *controller in self.viewControllers) {
        [controller setTableOffset: offset];
    }
    
    float lastPos = -225;
    float newPos = 0;
    
    newPos = lastPos - offset;
    lastPos = newPos;
    
    // Move
    self.bgImage.frame = CGRectMake(self.bgImage.frame.origin.x, newPos / 4, self.bgImage.frame.size.width, self.bgImage.frame.size.height);
}

-(void)removeBusStopController:(CHBusStopViewController *)controller
{
    
    int currentPageNum = self.pageControl.currentPage;
    int totalPageNum = self.pageControl.numberOfPages;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stops = [NSMutableArray arrayWithArray:[prefs arrayForKey:@"stops"]];
    
    if (stops.count > 1) {
        if (currentPageNum + 1 == totalPageNum) {
            // Get previous page
            UIView *view = [self.views objectAtIndex:currentPageNum-1];
            [self.scrollView scrollRectToVisible:view.frame animated:YES];
            if (stops.count == 2) {
                CHBusStopViewController *busStopController = (CHBusStopViewController *)[self.viewControllers objectAtIndex:0];
                busStopController.timeTableViewController.removeStopButton.hidden = YES;
            }

        } else {
            // Get next page
            UIView *view = [self.views objectAtIndex:currentPageNum + 1];
            [self.scrollView scrollRectToVisible:view.frame animated:YES];
            if (stops.count == 2) {
                CHBusStopViewController *busStopController = (CHBusStopViewController *)[self.viewControllers objectAtIndex:1];
                busStopController.timeTableViewController.removeStopButton.hidden = YES;
            }
            
        }
        
        
        
        self.hasJustDeleted = YES;
        self.idToDelete = controller.busStop.stop_id;

    }
}

#pragma mark - UIScrollView
- (void) setupScrollView
{
    for (int i = 0; i < self.views.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        [[self.viewControllers objectAtIndex:i] changeOffset:i*320];
        [[self.viewControllers objectAtIndex:i] setDelegate:self];

        
        UIView *view = [self.views objectAtIndex:i];
        view.frame = frame;
        [view removeFromSuperview];
        [self.scrollView addSubview:view];
        view.hidden = NO;
    }

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.views.count, self.scrollView.frame.size.height);
    
    self.pageControl.numberOfPages = self.views.count;
    pageNum = 0;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGFloat pageWidth = self.scrollView.bounds.size.width ;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	if (self.pageControl.currentPage != nearestNumber)
	{
		self.pageControl.currentPage = nearestNumber;
		// if we are dragging, we want to update the page control directly during the drag
		if (self.scrollView.dragging)
			[self.pageControl updateCurrentPageDisplay] ;
	}
    
    //[currentPage parentScrollViewDidMoveBy:self.scrollView.contentOffset.x];
    
    for (CHBusStopViewController *controller in self.viewControllers) {
        [controller parentScrollViewDidMoveBy:self.scrollView.contentOffset.x];
    }
}


- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stops = [NSMutableArray arrayWithArray:[prefs arrayForKey:@"stops"]];
    
    if (self.hasJustDeleted) {
        [stops removeObject:self.idToDelete];

        
        [prefs setObject:stops forKey:@"stops"];
        [prefs synchronize];
        
       
        self.hasJustDeleted = NO;
    }
}



@end
