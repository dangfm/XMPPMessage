//
//  LoadingView.h
//  DFMMessage
//
//  Created by dangfm on 14-6-28.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+(LoadingView*)instance;
-(void)start:(NSString*)title;
-(void)stop:(NSString*)title time:(CGFloat)time;
@end
