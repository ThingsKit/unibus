//
//  CHNavigationViewController.h
//  Warwick Unibus
//
//  Created by Chris Howell on 30/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

typedef enum {
    CHVerticalSlide
} CHAnimation;

#import <UIKit/UIKit.h>

@interface CHNavigationViewController : UIViewController

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;

- (void)addChildViewController:(UIViewController *)childController;
- (void)removeChildViewController:(UIViewController *)childController;

-(void)pushViewController: (UIViewController *) viewController;
-(void) popViewController: (UIViewController *) viewController;

-(void) pushViewController: (UIViewController *) viewController withAnimation:(CHAnimation)animation;

-(void) popViewController: (UIViewController *) viewController withAnimation:(CHAnimation)animation;;

@end
