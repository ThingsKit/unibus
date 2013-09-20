//
//  CHNoBusesCell.m
//  Warwick Unibus
//
//  Created by Chris Howell on 13/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHNoBusesCell.h"

@interface CHNoBusesCell()
@property (nonatomic, weak) IBOutlet UILabel *cellLabel;
@end

@implementation CHNoBusesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellType = WrongPeriodType;
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.cellType = WrongPeriodType;
    }
    return self;
}

- (id) initWithType: (NoBusesType) type
{
    self = [super init];
    if (self) {
        self.cellType = type;
        
    }
    return self;
}

- (void) setCellType:(NoBusesType)cellType
{
    _cellType = cellType;
    
    switch (_cellType) {
        case EndOfDayType:
            self.cellLabel.text = @"No more buses until the morning";
            break;
        case WrongPeriodType:
            self.cellLabel.text = @"No buses serve this stop today";
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
