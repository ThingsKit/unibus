//
//  CHTimetableViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 01/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHTimetableViewController.h"
#import "CHTimetableCell.h"

@interface CHTimetableViewController ()
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@end

@implementation CHTimetableViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeContentInsetTo:(UIEdgeInsets)inset
{
    self.tableView.contentInset = inset;
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, -inset.top)];
}

#pragma mark - UITableViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Move the next bus view and fade it out
    
    // Starts with offset 225
   // float lastPos = -225;
   // float newPos = 0;
    
    //newPos = lastPos - self.tableView.contentOffset.y ;
    //lastPos = newPos;
    
    // Move
    //self.nextBusView.frame = CGRectMake(self.nextBusView.frame.origin.x, MIN(32 + (newPos / 2), 32), self.nextBusView.frame.size.width, self.nextBusView.frame.size.height);
    
    // Fade
   // float percentage = -newPos / 100;
   // self.nextBusView.alpha = 1 - percentage;
    
    //[self.delegate CHBusStopTableviewDidMoveBy:self.tableView.contentOffset.y];
    NSLog(@"%g", self.tableView.contentOffset.y);
}

#pragma mark - UITableViewDelegate
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
    
    
    return cell;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // pass touch event by default implement.
    [super touchesBegan:touches withEvent:event];
    
    // redirect the touch events.
    //[anotherView touchesBegain:touches withEvent:event];
}

@end
