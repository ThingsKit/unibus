//
//  CHMainViewViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 24/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHBusStopViewController.h"
#import "CHNavigationViewController.h"


@interface CHMainViewViewController : UIViewController <UIScrollViewDelegate, CHBusStopViewControllerDelegate>
@property (nonatomic, weak) CHNavigationViewController *navigationController;

-(void)attemptImageDownload;
@end
