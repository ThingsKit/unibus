//
//  CHLoadingViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 09/09/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLoadingViewController : UIViewController
{
    void (^_completionHandler)(void);
}

- (void) fadeOutLoadingViewWithCompletion:(void(^)(void))handler;

@end
