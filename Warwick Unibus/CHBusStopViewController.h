//
//  CHBusStopViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 27/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

@class CHBusStopViewController;

#import <UIKit/UIKit.h>
#import "CHTimetableViewController.h"
#import "BusStop.h"


@protocol CHBusStopViewControllerDelegate <NSObject>
- (void) CHBusStopTableviewDidMoveBy: (float) offset;
- (void) removeBusStopController:(CHBusStopViewController *)controller;
@end

@interface CHBusStopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CHTimetableViewControllerDelegate>
@property (nonatomic, strong) BusStop *busStop;
@property (nonatomic, strong) CHTimetableViewController *timeTableViewController;
@property (nonatomic, assign) BOOL hideRemoveButton;

-(id)initWithBusStopId:(NSNumber*)id;

- (void) parentScrollViewDidMoveBy: (float) movement;
-(void)changeOffset:(float)offset;
-(void)setTableOffset:(float)offset;

@end
