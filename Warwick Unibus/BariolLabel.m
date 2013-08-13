//
//  BariolLabel.m
//  Warwick Unibus
//
//  Created by Chris Howell on 04/08/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "BariolLabel.h"

@implementation BariolLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Bariol-Regular"
                                size:self.font.pointSize];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
