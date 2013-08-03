//
//  CHBusStopViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 27/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHBusStopViewController.h"
#import "CHTimetableCell.h"
#import "CHTimetableViewController.h"

@interface CHBusStopViewController ()
@property (nonatomic, strong) IBOutlet UIView *timetableHeaderView;

@property (nonatomic, strong) IBOutlet UILabel *busStopName;

// Next bus view
@property (nonatomic, strong) IBOutlet UIView *nextBusView;
@property (nonatomic, strong) IBOutlet UILabel *nextBusTimeLabel;

@property (nonatomic, strong) CHTimetableViewController *timeTableViewController;

//Delegate
@property (nonatomic, weak) id <CHBusStopViewControllerDelegate> delegate;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) float offsetBy;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) float distance;


@end


@implementation CHBusStopViewController

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
    
    // Setup tableview
    self.timeTableViewController = [[CHTimetableViewController alloc] init];
    [self.view addSubview:self.timeTableViewController.view];
    [self.timeTableViewController changeContentInsetTo:UIEdgeInsetsMake(232, 0, 0, 0)];
    self.timeTableViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
//    
//    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 232, 320, 520-20)];
//    newView.backgroundColor = [UIColor blackColor];
//    newView.userInteractionEnabled = YES;
//    [self.view addSubview:newView];
//    
//    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userPanned:)];
//    
//    [newView addGestureRecognizer:self.panGesture];
}

-(IBAction)userPanned:(UIPanGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startLocation = [sender locationInView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
    } else {
        CGPoint stopLocation = [sender locationInView:self.view];
        CGFloat dy = stopLocation.y - self.startLocation.y;
        self.distance = dy;
        NSLog(@"Distance: %f", self.distance);
        
    }
    //[self.timeTableViewController ]
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
    
    NSLog(@"%g", movement);
    
    
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
    //[self.tableView setContentOffset:CGPointMake(self.tableView.frame.origin.x, offset)];
}


#pragma mark - UITableViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Move the next bus view and fade it out
    
    // Starts with offset 225
    float lastPos = -225;
    float newPos = 0;
    
    //newPos = lastPos - self.tableView.contentOffset.y ;
    lastPos = newPos;
    
    // Move
    self.nextBusView.frame = CGRectMake(self.nextBusView.frame.origin.x, MIN(32 + (newPos / 2), 32), self.nextBusView.frame.size.width, self.nextBusView.frame.size.height);
    
    // Fade
    float percentage = -newPos / 100;
    self.nextBusView.alpha = 1 - percentage;
    
    //[self.delegate CHBusStopTableviewDidMoveBy:self.tableView.contentOffset.y];
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
    
    [cell setupCell];
    
    return cell;
}


@end
