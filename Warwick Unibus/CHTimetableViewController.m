//
//  CHTimetableViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 01/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHTimetableViewController.h"
#import "CHTimetableCell.h"
#import "CHNoBusesCell.h"
#import "BusStop.h"
#import "BusTime.h"
#import "CoreData+MagicalRecord.h"

@interface CHTimetableViewController ()
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIButton *addStopButton;

@property (nonatomic, strong) NSMutableOrderedSet *busTimes;
@property (nonatomic, strong) NSMutableArray *busTimesLeftToday;
@property (nonatomic, strong) NSMutableArray *busTimesTomorrow;
@property (nonatomic, strong) NSMutableArray *busTimesTomorrowUnder24Hours;

@property (nonatomic, strong) BusTime *firstBus;
@property (nonatomic, strong) BusTime *lastBus;
@property (nonatomic, strong) BusTime *firstBusTomorrow;
@property (nonatomic, strong) BusTime *lastBusTomorrow;

@property (nonatomic, strong) NSDate *lastMinuteOfDayDate;

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
    self.addStopButton.hidden = YES;
    
    [self.addStopButton setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
    [self.addStopButton setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataSaved:) name:@"coreDataUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeChanged:) name:@"TimeChange" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setBusStop:(BusStop *)busStop
{
    _busStop = busStop;
    
    self.titleLabel.text = [[busStop.name stringByReplacingOccurrencesOfString:@"(up)" withString:@""] stringByReplacingOccurrencesOfString:@"(down)" withString:@""];
    self.addStopButton.hidden = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stops = [NSMutableArray arrayWithArray:[prefs arrayForKey:@"stops"]];
    for (NSNumber *number in stops) {
        if (number.intValue == self.busStop.stop_id.intValue) {
            [self.addStopButton setSelected:YES];
        } else {
            [self.addStopButton setSelected:NO];
        }
    }
    
    [self loadBusStopTimetable];
}

- (void) hideFavouriteButton
{
    self.addStopButton.hidden = YES;
}

-(void)changeContentInsetTo:(UIEdgeInsets)inset
{
    self.tableView.contentInset = inset;
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, -inset.top)];
}

- (void) loadBusStopTimetable {
    // Get the bus times for this stop
    NSMutableOrderedSet *busTimes = [self.busStop timetableSet];
    
    NSDate *now = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:now];
    int weekday = [comps weekday];
    
    NSString *queryString;
    if (weekday >= 2 && weekday <= 6) {
        // Mon-fri
        queryString = @"weekday";
    } else if (weekday == 7) {
        // Sat
        queryString = @"saturdays";
    } else {
        // Sun
        queryString = @"sundays";
    }
    
    NSString *queryStringTomorrow;
    weekday = (weekday + 1) % 8;
    if (weekday >= 2 && weekday <= 6) {
        // Mon-fri
        queryStringTomorrow = @"weekday";
    } else if (weekday == 7) {
        // Sat
        queryStringTomorrow = @"saturday";
    } else {
        // Sun
        queryStringTomorrow = @"sunday";
    }
    
    comps = [gregorian components:NSUIntegerMax fromDate:now];
    [comps setHour:23];
    [comps setMinute:59];
    [comps setSecond:59];
    
    self.lastMinuteOfDayDate = [gregorian dateFromComponents:comps];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop_id ==[c] %@ AND period ==[c] %@", self.busStop.stop_id, queryString];
    NSArray *busTimesForDay = [BusTime MR_findAllWithPredicate:predicate inContext:localContext];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sequenceNo" ascending:YES];
    busTimesForDay = [busTimesForDay sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicateTomorrow = [NSPredicate predicateWithFormat:@"stop_id ==[c] %@ AND period ==[c] %@", self.busStop.stop_id, queryStringTomorrow];
    NSArray *busTimesForTomorrow = [BusTime MR_findAllWithPredicate:predicateTomorrow inContext:localContext];
    busTimesForTomorrow = [busTimesForTomorrow sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
    // NEEDS FIXING FOR BUS TIMETABLES THAT GO ON TO EARLY MORNINGS
    self.firstBus = [busTimesForDay firstObject];
    self.lastBus = [busTimesForDay lastObject];
    
    self.firstBusTomorrow = [busTimesForTomorrow firstObject];
    self.lastBusTomorrow = [busTimesForTomorrow lastObject];
    
    self.busTimes = busTimes;
    
    self.busTimesLeftToday = [NSMutableArray arrayWithArray:busTimesForDay];
    self.busTimesTomorrow = [NSMutableArray arrayWithArray:busTimesForTomorrow];
    
    if (self.busTimesLeftToday == nil && self.busTimesTomorrow == nil) {
        NSLog(@"Nil values for bus time arrays at time: %@", [NSDate date]);
    }
    
    
    NSArray *sortedTimes = [self.busTimesLeftToday sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.busTimesLeftToday = [NSMutableArray arrayWithArray: sortedTimes];
    NSArray *sortedTomorrowTimes = [self.busTimesTomorrow sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.busTimesTomorrow = [NSMutableArray arrayWithArray:sortedTomorrowTimes];
}

#pragma mark - NSNotifications
- (void) coreDataSaved:(NSNotification *) notification
{
    [self loadBusStopTimetable];
    [self.tableView reloadData];
}

- (void) timeChanged:(NSNotification *) notification
{
    if (self.busTimesLeftToday.count == 0 && self.busTimesTomorrow == 0) {
        [self loadBusStopTimetable];
    }
    // Work out if 1 hour away from tomorrows first bus
    // if yes, update tomorrows buses to be todays
    // place no more buses after last bus
    
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDate *dateOneDayAhead = [now dateByAddingTimeInterval:oneDay];

    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:now];
    if ([self.lastMinuteOfDayDate earlierDate:now] == now) {
        // If right now is before midnight today
        components = [gregorian components:NSUIntegerMax fromDate:dateOneDayAhead];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *hours = [numberFormatter numberFromString:[self.firstBusTomorrow.time substringToIndex:2]];
    NSNumber *minutes = [numberFormatter numberFromString:[self.firstBusTomorrow.time substringFromIndex:2]];
    
    [components setHour:hours.intValue];
    [components setMinute:minutes.intValue];
    [components setSecond:0];
    
    NSDate *newDate = [gregorian dateFromComponents:components];
    
    newDate = [newDate dateByAddingTimeInterval:- 60 * 60];
    
    // If date one hour before tomorrows first bus is earlier than the date right now, we can reload the bus stop timetable data which will
    // set the busTimesLeftToday and busTimesTomorrow arrays
    if ([now earlierDate:newDate] == newDate) {
        [self loadBusStopTimetable];
    }
    
    components = [gregorian components:NSUIntegerMax fromDate:now];
    
    // Remove all times that have passed
    NSMutableArray *busStopsToRemove = [NSMutableArray new];
    for (BusTime *time in self.busTimesLeftToday) {
       
        
        NSNumber *hours = [numberFormatter numberFromString:[time.time substringToIndex:2]];
        NSNumber *minutes = [numberFormatter numberFromString:[time.time substringFromIndex:2]];

        [components setHour:hours.intValue];
        [components setMinute:minutes.intValue];
        [components setSecond:0];

        newDate = [gregorian dateFromComponents:components];

        if ([newDate earlierDate:now] == newDate) {
            [busStopsToRemove addObject:time];

        }
    }
    [self.busTimesLeftToday removeObjectsInArray:busStopsToRemove];
    
    // Only show bus times tomorrow that are under 24 hours away
    self.busTimesTomorrowUnder24Hours = [NSMutableArray new];
    
    
    for (BusTime *time in self.busTimesTomorrow) {
        
        if ([now earlierDate:self.lastMinuteOfDayDate] == self.lastMinuteOfDayDate) {
            // If it is after midnight
            components = [gregorian components:NSUIntegerMax fromDate:now];
        } else {
            components = [gregorian components:NSUIntegerMax fromDate:dateOneDayAhead];
        }
        
        NSNumber *hours = [numberFormatter numberFromString:[time.time substringToIndex:2]];
        NSNumber *minutes = [numberFormatter numberFromString:[time.time substringFromIndex:2]];
        
        [components setHour:hours.intValue];
        [components setMinute:minutes.intValue];
        [components setSecond:0];
        
        NSDate *newDate = [gregorian dateFromComponents:components];
        
        // To catch dates that are in the early hours of the morning we must set them to be the correct time frame ahead
        if ([newDate earlierDate:now] == newDate) {
            newDate = [newDate dateByAddingTimeInterval:24 * 60 * 60];
        }
        
        if ([dateOneDayAhead earlierDate:newDate] == newDate) {
            [self.busTimesTomorrowUnder24Hours addObject:time];
        }
    }
    
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    components = [gregorian components:NSUIntegerMax fromDate:now];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    if (self.busTimesLeftToday.count > 0) {
        NSNumber *hours = [numberFormatter numberFromString:[((BusTime *)self.busTimesLeftToday.firstObject).time substringToIndex:2]];
        NSNumber *minutes = [numberFormatter numberFromString:[((BusTime *)self.busTimesLeftToday.firstObject).time substringFromIndex:2]];
        
        [components setHour:hours.intValue];
        [components setMinute:minutes.intValue];
        [components setSecond:0];
        
       newDate = [gregorian dateFromComponents:components];
        
        NSTimeInterval differenceInSeconds = [newDate timeIntervalSinceDate:now];
        int minutesToDisplay = ceil(differenceInSeconds / 60);
  
        self.nextBusDue = minutesToDisplay;
        self.nextBusNumber = ((BusTime *)self.busTimesLeftToday.firstObject).number;
        self.nextBusTime = [self timeFormattedForHours:hours minutes:minutes];
        
        self.nextBusDestination = ((BusTime *)self.busTimesLeftToday.firstObject).destination;
    } else {
        // Get bus time for tomorrows first bus!
        NSNumber *hours = [numberFormatter numberFromString:[((BusTime *)self.busTimesTomorrow.firstObject).time substringToIndex:2]];
        NSNumber *minutes = [numberFormatter numberFromString:[((BusTime *)self.busTimesTomorrow.firstObject).time substringFromIndex:2]];

        self.nextBusDue = 100;
        self.nextBusNumber = ((BusTime *)self.busTimesTomorrow.firstObject).number;
        self.nextBusTime = [self timeFormattedForHours:hours minutes:minutes];
        
        self.nextBusDestination = ((BusTime *)self.busTimesTomorrow.firstObject).destination;
    }
    
    [self.tableView reloadData];
}

- (NSString *) timeFormattedForHours:(NSNumber *) hours minutes:(NSNumber *)minutes
{
    NSString *minutesString = @"";
    minutesString = [minutes stringValue];
    
    if (minutes.intValue < 10) {
        minutesString = [NSString stringWithFormat:@"0%@",minutes];
    }
    
    return [NSString stringWithFormat:@"%@:%@", hours, minutesString];
}

- (NSArray *) busTimesForNext24Hours
{
    
    NSMutableArray *busTimes = [NSMutableArray new];
    
    [busTimes addObjectsFromArray:self.busTimesLeftToday];
    [busTimes addObjectsFromArray:self.busTimesTomorrowUnder24Hours];
    
    for (int i = 0; i < busTimes.count; i++) {
        
        // Skip a null value
        if ([busTimes objectAtIndex:i] == [NSNull null]) {
            continue;
        }
        
        BusTime *time = [busTimes objectAtIndex:i];
        
        if ([time.lastBus isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            [busTimes insertObject:[NSNull null] atIndex:i + 1];
        }
        
        // Edge case: if user loads bus timetable in early morning, we must still show "no more buses"
        if ([time.firstBus isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            if (i == 0) {
                [busTimes insertObject:[NSNull null] atIndex:0];
            }
        }
    }
    
//    // Edge case: if user adds bus stop in early hours of the morning, we must make sure it adds the cell "no more buses" at the start
//    if ([self.busTimesTomorrowUnder24Hours count] == 0 && [self.busTimesLeftToday count] > 0 && [busTimes objectAtIndex:0] == [NSNull null]) {
//        [busTimes insertObject:[NSNull null] atIndex:0];
//    }
        
    return busTimes;
}

#pragma mark - UIButton event
- (IBAction)addStopButtonPressed:(id)sender
{
    // Add bus stop to list
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stops = [NSMutableArray arrayWithArray:[prefs arrayForKey:@"stops"]];

    if ([sender isSelected]) {
        [stops removeObject:[NSNumber numberWithInt:self.busStop.stop_id.intValue]];
        [prefs setObject:stops forKey:@"stops"];
        [sender setSelected:NO];
        [self.delegate userDidUnfavouriteStop];
    } else {
        [stops addObject:[NSNumber numberWithInt:self.busStop.stop_id.intValue] ];
        [prefs setObject:stops forKey:@"stops"];
        
        [sender setSelected:YES];
        [self.delegate userDidFavouriteStop];
    }
    [prefs synchronize];

    // Remove bus stop from list
}

- (IBAction)removeStopButtonPressed:(id)sender
{
    [self.delegate removeStopButtonPressed];
}

#pragma mark - UITableViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Tell delegate that the timetable was scrolled
    [self.delegate scrollViewDidScrollBy:scrollView.contentOffset.y];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self busTimesForNext24Hours] count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell;
    
    int row = indexPath.row;
    if ([[self busTimesForNext24Hours] objectAtIndex:indexPath.row] == [NSNull null]) {
        static NSString *CellIdentifier = @"CHNoBusesCell";
        cell = (CHTimetableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CHNoBusesCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = (CHTimetableCell *)[topLevelObjects objectAtIndex:0];
        }

    } else {
        static NSString *CellIdentifier = @"CHTimetableCell";
        cell = (CHTimetableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CHTimetableCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = (CHTimetableCell *)[topLevelObjects objectAtIndex:0];
        }
        BusTime *timeForCell = [[self busTimesForNext24Hours] objectAtIndex:row];
        [cell setupWithBusTime:timeForCell];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self busTimesForNext24Hours] objectAtIndex:indexPath.row] == [NSNull null]) {
        return 90;
    } else {
        return 45;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // pass touch event by default implement.
    [super touchesBegan:touches withEvent:event];
    
    // redirect the touch events.
    //[anotherView touchesBegain:touches withEvent:event];
}

@end
