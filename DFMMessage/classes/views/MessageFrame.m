//
//  MessageFrame.m
//  DFMMessage
//
//  Created by dangfm on 14-5-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "MessageFrame.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import <AVFoundation/AVFoundation.h>

@interface MessageFrame(){
    NSData *_data;
}

@end

@implementation MessageFrame

- (void)setMessage:(EMessages *)message{
    
    _message = message;
    
    // 0、获取屏幕宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // 1、计算时间的位置
    if (_showTime){
        
        CGFloat timeY = kMargin;
        //        CGSize timeSize = [_message.time sizeWithAttributes:@{UIFontDescriptorSizeAttribute: @"16"}];
        CGSize timeSize = [[CommonOperation toDescriptionStringWithTimestamp:_message.time] sizeWithFont:kTimeFont];
        NSLog(@"----%@", NSStringFromCGSize(timeSize));
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + kTimeMarginW, timeSize.height + kTimeMarginH);
    }
    // 2、计算头像位置
    CGFloat iconX = kMargin;
    // 2.1 如果是自己发得，头像在右边
    if (_message.messageType == 0) {
        iconX = screenW - kMargin - kIconWH;
    }
    
    CGFloat iconY = CGRectGetMaxY(_timeF) + kMargin;
    _iconF = CGRectMake(iconX, iconY, kIconWH, kIconWH);
    
    // 3、计算内容位置
    NSString *body = _message.content;
    
    CGFloat contentX = CGRectGetMaxX(_iconF) + kMargin;
    CGFloat contentY = iconY;
    CGSize contentSize ;
    if ([body hasPrefix:@"base64"]) {
        body = @" ";
        contentSize = [body sizeWithFont:kContentFont constrainedToSize:CGSizeMake(kContentW, CGFLOAT_MAX)];
        CGFloat w = 10*_message.second;
        if (w>170) {
            w = 170;
        }
        contentSize = CGSizeMake(w, contentSize.height);
    }
    else{
        contentSize = [body sizeWithFont:kContentFont constrainedToSize:CGSizeMake(kContentW, CGFLOAT_MAX)];
    }
    if (_message.messageType == 0) {
        contentX = iconX - kMargin - contentSize.width - kContentLeft - kContentRight;
    }
    
    _contentF = CGRectMake(contentX, contentY, contentSize.width + kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    
    // 4、计算高度
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF))  + kMargin;
    
    // 5、计算未读点的位置
    if (_message.messageType==0) {
    }else{
        _pointF = CGRectMake(contentX+contentSize.width + kContentLeft + kContentRight+20, contentY, 5, 5);
    }
    
}

@end

