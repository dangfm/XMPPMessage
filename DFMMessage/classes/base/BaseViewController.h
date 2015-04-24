//
//  BaseViewController.h
//  dapai
//
//  Created by dangfm on 14-4-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic,retain) UIView *header;// 导航视图
@property (nonatomic,retain) UIView *footer;// 底部导航视图
@property (nonatomic,retain) UILabel *titler; // 标题
@property (nonatomic,assign) int returnType;

#pragma mark 初始化导航
-(void)initNavigationWithTitle:(NSString*)title IsBack:(BOOL)back ReturnType:(int)returnType;
-(void)titleWithName:(NSString*)name;
@end
