//
//  CHTimetableCell.m
//  Warwick Unibus
//
//  Created by Chris Howell on 25/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHTimetableCell.h"
#import "UIColor+AppColors.h"

@interface CHTimetableCell ()
@property (nonatomic, weak) IBOutlet UILabel *destinationLabel;
@property (nonatomic, weak) IBOutlet UILabel *dueTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *busNumber;
@property (nonatomic, weak) IBOutlet UIImageView *busNumberImageView;

@end

@implementation CHTimetableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setupCell
{
    self.destinationLabel.textColor = [UIColor blueGreyColour];
    self.dueTimeLabel.textColor = [UIColor blueGreyColour];
}

- (void) setupWithBusTime:(BusTime *)time
{
    if ([time.destination isEqualToString:@"sydenham"]) {
        self.destinationLabel.text = @"Leamington Spa";
    } else if ([time.destination isEqualToString:@"uni"]){
        self.destinationLabel.text = @"University";
    }
    
    self.busNumber.text = [time.number capitalizedString];
    
    if ([time.number isEqualToString:@"u1"]) {
        self.busNumberImageView.image = [UIImage imageNamed:@"green.png"];
    }
    
    if ([time.number isEqualToString:@"u2"] || [time.number isEqualToString:@"u12"]) {
        self.busNumberImageView.image = [UIImage imageNamed:@"orange.png"];
    }
    
    if ([time.number isEqualToString:@"u17"]) {
        self.busNumberImageView.image = [UIImage imageNamed:@"red.png"];
    }
    
    // Get all times that are in the next hour and change them to be in minutes
    NSDate *now = [NSDate date];
    
    NSTimeInterval oneHour = 60 * 60;
    NSDate *dateOneHourAhead = [now dateByAddingTimeInterval:oneHour];
        
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:now];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *hours = [numberFormatter numberFromString:[time.time substringToIndex:2]];
    NSNumber *minutes = [numberFormatter numberFromString:[time.time substringFromIndex:2]];
    
    [components setHour:hours.intValue];
    [components setMinute:minutes.intValue];
    [components setSecond:0];
    
    NSDate *newDate = [gregorian dateFromComponents:components];
    
    if ([newDate earlierDate:now] == now && [newDate laterDate:dateOneHourAhead] == dateOneHourAhead) {
        NSTimeInterval differenceInSeconds = [newDate timeIntervalSinceDate:now];
        int minutesToDisplay = ceil(differenceInSeconds / 60);
        
        if (minutesToDisplay <= 2 ) {
            self.dueTimeLabel.text = [NSString stringWithFormat:@"Due"];
        } else {
            self.dueTimeLabel.text = [NSString stringWithFormat:@"%i mins", minutesToDisplay];
        }
        
    } else {
        NSString *busTime = time.time ;
        NSString *firstPartOfTime = [busTime substringToIndex:2];
        NSString *secondPartOfTime = [busTime substringFromIndex:2];
        
        NSString *formattedTime = [NSString stringWithFormat:@"%@:%@", firstPartOfTime, secondPartOfTime];
        
        self.dueTimeLabel.text = formattedTime;
        
    }
        
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) setBgViewHidden
{
    self.bgView.hidden = YES;
}

@end
