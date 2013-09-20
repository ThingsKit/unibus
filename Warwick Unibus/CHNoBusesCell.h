//
//  CHNoBusesCell.h
//  Warwick Unibus
//
//  Created by Chris Howell on 13/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EndOfDayType,
    WrongPeriodType
} NoBusesType;

@interface CHNoBusesCell : UITableViewCell
@property (nonatomic, assign) NoBusesType cellType;



@end
