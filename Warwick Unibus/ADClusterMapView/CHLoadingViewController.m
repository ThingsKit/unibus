//
//  CHLoadingViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 09/09/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHLoadingViewController.h"

@interface CHLoadingViewController ()
@end

@implementation CHLoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) fadeOutLoadingViewWithCompletion:(void(^)(void))handler
{
    // Copy it so it doesnt disappear!
    _completionHandler = [handler copy];
    
    // Do our fade
    [UIView animateWithDuration:1
                          delay:0.2f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^(){}
                     completion:^(BOOL fin) {
                         // Call completion
                         [UIView animateWithDuration:1
                                               delay:0.2f
                                             options:UIViewAnimationCurveEaseInOut
                                          animations:^(){self.view.alpha = 0;}
                                          completion:^(BOOL fin) {
                                              // Call completion
                                              _completionHandler();
                                          }];
                     }];
}

@end
