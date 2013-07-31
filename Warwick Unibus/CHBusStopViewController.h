//
//  CHBusStopViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 27/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHBusStopViewControllerDelegate <NSObject>
- (void) CHBusStopTableviewDidMoveBy: (float) offset;

@end

@interface CHBusStopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void) parentScrollViewDidMoveBy: (float) movement;
-(void)changeOffset:(float)offset;
-(void)setTableOffset:(float)offset;
-(void)transitionOut;

@end
