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

@interface CHMainViewViewController ()

@property (nonatomic, strong) IBOutlet UIButton *mapButton;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet NSArray *views;
@property (nonatomic, strong) IBOutlet NSArray *viewControllers;
@property (nonatomic, strong) IBOutlet CHBusStopViewController *busStopTest;
@property (nonatomic, strong) IBOutlet CHBusStopViewController *busStopTest2;
@property (nonatomic, strong) IBOutlet CHBusStopViewController *busStopTest3;

@property (nonatomic, strong) IBOutlet UIImageView *bgImage;

@property (nonatomic, strong) IBOutlet CHMapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet UIView *mapView;

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

    [self setupScrollView];
    
    self.mapViewController = [[CHMapViewController alloc] init];
    

    isScrolling = NO;
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

#pragma mark - UIButton events
-(IBAction)mapButtonWasPressed:(id)sender
{
    [self presentViewController:self.mapViewController animated:YES completion:nil];

}

#pragma mark - CHBusStopViewControllerDelegate
-(void)CHBusStopTableviewDidMoveBy:(float)offset
{
    for (CHBusStopViewController *controller in self.viewControllers) {
        [controller setTableOffset: offset];
    }
}

#pragma mark - UIScrollView
- (void) setupScrollView
{
    self.busStopTest = [[CHBusStopViewController alloc] init];
    self.busStopTest2 = [[CHBusStopViewController alloc] init];
    self.busStopTest3 = [[CHBusStopViewController alloc] init];

    self.viewControllers = [NSArray arrayWithObjects:self.busStopTest, self.busStopTest2, self.busStopTest3, nil];
    self.views = [NSArray arrayWithObjects:self.busStopTest.view,self.busStopTest2.view, self.busStopTest3.view, nil];
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
		pageNum = nearestNumber;
		// if we are dragging, we want to update the page control directly during the drag
		//if (self.scrollView.dragging)
		//	[self.pageControl updateCurrentPageDisplay] ;
	}
    
    //[currentPage parentScrollViewDidMoveBy:self.scrollView.contentOffset.x];
    
    for (CHBusStopViewController *controller in self.viewControllers) {
        [controller parentScrollViewDidMoveBy:self.scrollView.contentOffset.x];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = pageNum;
    isScrolling = NO;
  
}



@end
