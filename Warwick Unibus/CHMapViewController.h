//
//  CHMapViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 29/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHNavigationViewController.h"
#import <MapKit/MapKit.h>
#import "ADClusterMapView.h"
#import "CHTimetableViewController.h"

@interface CHMapViewController : UIViewController <MKMapViewDelegate, CHTimetableViewControllerDelegate>
@property (nonatomic, weak) CHNavigationViewController *navController;
+ (CHMapViewController*)sharedMap;
@end
