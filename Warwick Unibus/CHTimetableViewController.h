//
//  CHTimetableViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 01/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTableView.h"
@class BusStop;

@protocol CHTimetableViewControllerDelegate <NSObject>
@optional
- (void) scrollViewDidScrollBy:(CGFloat) offset;
- (void) userDidFavouriteStop;
- (void) userDidUnfavouriteStop;
- (void) removeStopButtonPressed;
@end



@interface CHTimetableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet CHTableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) BusStop *busStop;
@property (nonatomic, weak) IBOutlet UIButton *removeStopButton;
@property (nonatomic, assign) int nextBusDue;
@property (nonatomic, strong) NSString *nextBusTime;
@property (nonatomic, strong) NSString *nextBusDestination;

@property (nonatomic, weak) id <CHTimetableViewControllerDelegate> delegate;


-(void)changeContentInsetTo:(UIEdgeInsets)inset;
-(void)hideFavouriteButton;

@end
