//
//  CHNavigationViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 30/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHNavigationViewController.h"

@interface CHNavigationViewController ()
@property (nonatomic, strong) NSArray *childViewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic) BOOL lightStatusBar;
-(void)verticalSlideFromViewController:(UIViewController *) fromController toViewController:(UIViewController *)toController duration:(NSTimeInterval)duration;
@end

@implementation CHNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.lightStatusBar = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if (self.lightStatusBar == NO) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }


}

- (void) setRootViewController:(UIViewController *)rootViewController
{
    self.currentViewController = rootViewController;
    _rootViewController = rootViewController;
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration animations:(void (^)(UIViewController*, UIViewController*))animations completion:(void (^)(BOOL))completion
{
    //[UIView animateWithDuration:duration animations:animations completion:completion];
}

-(void)addChildViewController:(UIViewController *)childController
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.childViewControllers];
    [array addObject:childController];
    self.childViewControllers = array;
}

-(void)removeChildViewController:(UIViewController *)childController
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.childViewControllers];
    [array removeObject:childController];
    self.childViewControllers = array;
}

#pragma mark - Animations
-(void)verticalSlideFromViewController:(UIViewController *) fromController toViewController:(UIViewController *)toController mode:(TransitionMode) mode duration:(NSTimeInterval)duration
{
    float movementValue;
    if (mode == Push) {
        movementValue = -568;
        [self.view addSubview:toController.view];
    } else {
        movementValue = 568;
    }
    
    
    
    
    toController.view.frame = CGRectMake(toController.view.frame.origin.x, - movementValue, toController.view.frame.size.width, toController.view.frame.size.height);
    [UIView animateWithDuration:duration animations:^(void){
        fromController.view.frame = CGRectMake(fromController.view.frame.origin.x, fromController.view.frame.origin.y + movementValue, fromController.view.frame.size.width, fromController.view.frame.size.height);
        toController.view.frame = CGRectMake(toController.view.frame.origin.x, 0, toController.view.frame.size.width, toController.view.frame.size.height);
    }];
    
    self.currentViewController = toController;
}

#pragma mark - Push/pop animated

-(void)pushViewController:(UIViewController *)viewController withAnimation:(CHAnimation)animation
{
    switch (animation) {
        case CHVerticalSlide:
            [self addChildViewController:viewController];
            [self verticalSlideFromViewController:self.currentViewController toViewController:viewController mode:Push duration:0.5];
            break;
            
        default:
            
            break;
    }
}

- (void) popViewController:(UIViewController *)viewController withAnimation:(CHAnimation) animation
{
    switch (animation) {
        case CHVerticalSlide:
        {
            UIViewController *prevController = [self.childViewControllers objectAtIndex:self.childViewControllers.count - 2];
            [self verticalSlideFromViewController:self.currentViewController toViewController:prevController mode:Pop duration:0.5];
            [self removeChildViewController:viewController];
        }
        break;
            
        default:
            
            break;
    }
}


#pragma mark - Push/pop
-(void)pushViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
}

-(void)popViewController:(UIViewController *)viewController
{
    [viewController.view removeFromSuperview];
    [self removeChildViewController:viewController];
}


#pragma mark - Status bar
-(void)setStatusBarWithStyle:(UIStatusBarStyle) style
{
    switch (style) {
        case UIStatusBarStyleDefault:
            self.lightStatusBar = NO;
            break;
        case UIStatusBarStyleLightContent:
            self.lightStatusBar = YES;
            break;
        default:
            break;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}
@end
