//
//  AppDelegate.h
//  DFMMessage
//
//  Created by dangfm on 14-5-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@class LoginViewController;
@protocol ChatDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPRosterDelegate>
{
    
}

@property (nonatomic,retain) XMPPServer *xmppServer;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) LoginViewController *loginViewController;

-(void)initViews;
-(void)free;

@end

