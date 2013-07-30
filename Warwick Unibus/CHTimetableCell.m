//
//  CHTimetableCell.m
//  Warwick Unibus
//
//  Created by Chris Howell on 25/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import "CHTimetableCell.h"
#import "UIColor+AppColors.h"

@interface CHTimetableCell ()
@property (nonatomic, strong) IBOutlet UILabel *destinationLabel;
@property (nonatomic, strong) IBOutlet UILabel *dueTimeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *busNumberImageView;
@end

@implementation CHTimetableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setupCell
{
    self.destinationLabel.textColor = [UIColor blueGreyColour];
    self.dueTimeLabel.textColor = [UIColor blueGreyColour];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) setBgViewHidden
{
    self.bgView.hidden = YES;
}

@end
