//
//  CHTable.m
//  Warwick Unibus
//
//  Created by Chris Howell on 01/09/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHTableView.h"

@implementation CHTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hidden) {
        return nil;
    }
    
    CGFloat nowOffset = self.contentOffset.y;
    CGFloat difference = -self.startOffset - nowOffset;
    
    //    NSLog(@"difference: %g", difference);
    //    NSLog(@"topLine: %g", -self.startOffset - difference);
    //    NSLog(@"superview: %@",self.superview);
    
    CGPoint convertedPoint = [self.superview convertPoint:point fromView:self];
    //    NSLog(@"point: %g", convertedPoint.y);
    
    if (convertedPoint.y >= -(-self.startOffset - difference)){
        if ([self.tableHeaderView hitTest:point withEvent:event]) {
            return [self.tableHeaderView hitTest:point withEvent:event];
        }
        for (UIView *view in self.subviews) {
            if ([view hitTest:point withEvent:event] != nil)
                return [view hitTest:point withEvent:event];
        }
        return self;
    } else {
        return nil;
    }
    //[self pointInside:point withEvent:event];
    
}

@end
