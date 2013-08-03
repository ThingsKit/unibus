//
//  CHTimetableViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 01/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTimetableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

-(void)changeContentInsetTo:(UIEdgeInsets)inset;

@end
