//
//  MyTableViewCell.m
//  DFMMessage
//
//  Created by 21tech on 14-6-18.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "MyTableViewCell.h"

@implementation MyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *view = [[UIView alloc] initWithFrame:self.contentView.frame];
        view.backgroundColor = kCellPressBackground;
        self.selectedBackgroundView = view;
        view = nil;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
