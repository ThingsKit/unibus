//
//  BariolBold.m
//  Warwick Unibus
//
//  Created by Chris Howell on 04/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "BariolBold.h"

@implementation BariolBold

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Bariol-Bold"
                                size:self.font.pointSize];
}

@end
