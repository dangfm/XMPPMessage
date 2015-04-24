//
//  SmallCircleCellFrame.m
//  DFMMessage
//
//  Created by 21tech on 14-6-25.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "SmallCircleCellFrame.h"
#import "EUserPages.h"

@implementation SmallCircleCellFrame

- (void)setUserPages:(EUserPages *)userPages{
    _userPages = userPages;
    
    // 计算头像位置
    CGFloat iconX = kMargin;

    CGFloat iconY = CGRectGetMaxY(_timeF) + kMargin;
    _iconF = CGRectMake(iconX, iconY, kIconWH, kIconWH);
    
    // 计算内容位置
    NSString *body = _userPages.content;
    
    CGFloat contentX = CGRectGetMaxX(_iconF) + kMargin;
    CGFloat contentY = iconY;
    CGSize contentSize ;
    
    contentSize = [body sizeWithFont:kContentFont constrainedToSize:CGSizeMake(kContentW, CGFLOAT_MAX)];
    
    _contentF = CGRectMake(contentX, contentY, contentSize.width + kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    
    // 计算高度
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF))  + kMargin;
    
}

@end
