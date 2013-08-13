//
//  CHTimetableCell.h
//  Warwick Unibus
//
//  Created by Chris Howell on 25/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusTime.h"

@interface CHTimetableCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *bgView;

- (void) setBgViewHidden;
- (void) setupWithBusTime:(BusTime *)time;
- (void) displayMinutes;
@end
