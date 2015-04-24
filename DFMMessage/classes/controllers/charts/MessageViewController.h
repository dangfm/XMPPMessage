//
//  MessageViewController.h
//  DFMMessage
//
//  Created by dangfm on 14-5-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "XMPPFramework.h"

@interface MessageViewController : BaseViewController

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UITextField *messageField;
@property (retain, nonatomic) UIButton *speakBtn;
@property (retain, nonatomic) XMPPJID *toJID;

@end
