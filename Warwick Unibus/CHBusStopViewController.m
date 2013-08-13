//
//  CHBusStopViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 27/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHBusStopViewController.h"
#import "CHTimetableCell.h"
#import "CHDataLoader.h"
#import <iAd/iAd.h>

@interface CHBusStopViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *statusBarBackground;
@property (nonatomic, weak) IBOutlet UILabel *busStopName;

@property (nonatomic, strong) IBOutlet UIView *universityDestinationView;
@property (nonatomic, strong) IBOutlet UIView *leamingtonDestinationView;

// Next bus view
@property (nonatomic, weak) IBOutlet UIView *nextBusView;
@property (nonatomic, weak) IBOutlet UILabel *nextBusTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *minutesLabel;
@property (nonatomic, weak) IBOutlet UILabel *destinationLabel;

//Delegate
@property (nonatomic, weak) id <CHBusStopViewControllerDelegate> delegate;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) float offsetBy;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) float distance;


@end


@implementation CHBusStopViewController

-(void)awakeFromNib
{

    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithBusStopId:(NSNumber*)id
{
    self = [super init];
    if (self)
    {
        self.busStop = [CHDataLoader busStopWithId:id];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTimetableViewController];
    [self populateBusStopData];
    
//    UIInterpolatingMotionEffect *mx = [[UIInterpolatingMotionEffect alloc]
//                                       initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    mx.maximumRelativeValue = @39.0;
//    mx.minimumRelativeValue = @-39.0;
//    
//    UIInterpolatingMotionEffect *mx2 = [[UIInterpolatingMotionEffect alloc]
//                                        initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    mx2.maximumRelativeValue = @39.0;
//    mx2.minimumRelativeValue = @-39.0;
//    
//    //Make sure yourView's bounds are beyond the canvas viewport - because it's being moved by values.
//    
//    [self.nextBusView addMotionEffect:mx];
//    [self.nextBusView addMotionEffect:mx2];
    
    // Set to be invisible so that we can fade it in and out later
    [self.view bringSubviewToFront:self.statusBarBackground];
    self.statusBarBackground.alpha = 0;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeChanged:) name:@"TimeChange" object:nil];
   
}

- (void) setupTimetableViewController
{
    self.timeTableViewController = [[CHTimetableViewController alloc] init];
    [self.view addSubview:self.timeTableViewController.view];
    [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(232, 0, 0, 0)];
    self.timeTableViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.timeTableViewController.tableView setViewToReturnTo:self.view];
    self.timeTableViewController.delegate = self;
    self.timeTableViewController.tableView.startOffset = 232;
    
    if (self.hideRemoveButton) {
        self.timeTableViewController.removeStopButton.hidden = YES;
    } else {
        self.timeTableViewController.removeStopButton.hidden = NO;
    }
}

- (void) populateBusStopData
{
    self.timeTableViewController.busStop = self.busStop;
    [self.timeTableViewController hideFavouriteButton];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) parentScrollViewDidMoveBy: (float) movement
{
    // Move and fade the nextBus view
    // Move the next bus view and fade it out
    
    float lastPos = 0 + self.offsetBy;
    float newPos = 0;
    
    newPos = lastPos - movement;
    lastPos = newPos;
    
    // Move
    self.nextBusView.frame = CGRectMake(newPos/2, self.nextBusView.frame.origin.y, self.nextBusView.frame.size.width, self.nextBusView.frame.size.height);
    
    // Fade
    //float percentage = -newPos / 100;
    //self.nextBusView.alpha = 1 - percentage;
}

- (void)changeOffset:(float)offset
{
    self.offsetBy = offset;
}

-(void)setTableOffset:(float)offset
{
    [self.timeTableViewController.tableView setContentOffset:CGPointMake(self.timeTableViewController.tableView.frame.origin.x, offset)];
}

- (void) timeChanged:(NSNotification *) notification
{
    if ([self.timeTableViewController.nextBusDestination isEqualToString:@"sydenham"]) {
        [self.universityDestinationView removeFromSuperview];
        [self.nextBusView addSubview:self.leamingtonDestinationView];
        self.leamingtonDestinationView.frame = CGRectMake(0, 145, 320, 40);
    } else {
        [self.leamingtonDestinationView removeFromSuperview];
        [self.nextBusView addSubview:self.universityDestinationView];
        self.universityDestinationView.frame = CGRectMake(0, 145, 320, 40);
    }
    
    if (self.timeTableViewController.nextBusDue <= 2) {
        self.nextBusTimeLabel.text = @"DUE";
        self.minutesLabel.hidden = YES;
    } else if (self.timeTableViewController.nextBusDue >= 60) {
        self.nextBusTimeLabel.text = self.timeTableViewController.nextBusTime;
        self.minutesLabel.hidden = YES;
    } else {
        self.nextBusTimeLabel.text = [NSString stringWithFormat:@"%i",self.timeTableViewController.nextBusDue];
        self.minutesLabel.hidden = NO;
    }
    
}

#pragma mark - CHTimetableViewControllerDelegate
- (void) scrollViewDidScrollBy:(CGFloat) offset
{
    // Move the next bus view and fade it out
    
    // Starts with offset 225
    float lastPos = -225;
    float newPos = 0;
    
    newPos = lastPos - offset;
    lastPos = newPos;
    
    // Move
    self.nextBusView.frame = CGRectMake(self.nextBusView.frame.origin.x, MIN(32 + (newPos / 2), 32), self.nextBusView.frame.size.width, self.nextBusView.frame.size.height);
    
    // Fade
    float percentage = -newPos / 100;
    self.nextBusView.alpha = 1 - percentage;
    
    // Fade the status bar background (needed because otherwise we cant see it!
    newPos = lastPos + 70 - offset + 70 ;
    percentage = -newPos / 100;
    self.statusBarBackground.alpha = 0 + percentage;
    
    
    
    
    [self.delegate CHBusStopTableviewDidMoveBy:offset];
}

- (void) removeStopButtonPressed
{
    [self.delegate removeBusStopController:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell;
    
    static NSString *CellIdentifier = @"TimetableCell";
    cell = (CHTimetableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CHTimetableCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = (CHTimetableCell *)[topLevelObjects objectAtIndex:0];
    }
    
    if (indexPath.row % 2 != 0) {
        [cell setBgViewHidden];
    }
    
    //[cell setupCell];
    
    return cell;
}


@end
