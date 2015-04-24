//
//  SmallCircleTableViewCell.m
//  DFMMessage
//
//  Created by 21tech on 14-6-25.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "SmallCircleTableViewCell.h"

@interface SmallCircleTableViewCell(){
    
}

@end

@implementation SmallCircleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

-(void)setUserPages:(EUserPages *)userPages{
    
}

@end
