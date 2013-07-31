//
//  CHMapViewController.m
//  Warwick Unibus
//
//  Created by Chris Howell on 29/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHMapViewController.h"

@interface CHMapViewController ()

@property (nonatomic, strong) IBOutlet UIButton *doneButton;

@end

@implementation CHMapViewController

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


#pragma mark - UIButton events
-(IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
