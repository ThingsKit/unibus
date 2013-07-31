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
@end

@implementation CHNavigationViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:duration animations:animations completion:completion];
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


#pragma mark - Push/pop animated
void (^VerticalSlide)(void) = ^void (void)
{
    
};

-(void)pushViewController:(UIViewController *)viewController withAnimation:(CHAnimation)animation
{
    switch (animation) {
        case CHVerticalSlide:
            [self transitionFromViewController:self.currentViewController toViewController:viewController duration:1 animations:VerticalSlide completion:nil];
            break;
            
        default:
            [self transitionFromViewController:self.currentViewController toViewController:viewController duration:0 animations:Default completion:nil];
            break;
    }
}

- (void) popViewController:(UIViewController *)viewController withAnimation:(CHAnimation) animation
{
    
}


#pragma mark - Push/pop
-(void)pushViewController:(UIViewController *)viewController
{
    
}

-(void)popViewController:(UIViewController *)viewController
{
    
}

@end
