//
//  XMPPServer.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@protocol XMPPChatDelegate <NSObject>
@optional
/**
 XMPP服务器连接状态指示
 @state           状态指示类型  -1=连接失败 0=未连接 1=正在连接 2=已连接 3=断开连接 4=连接超时 5=验证错误 6=接收中 7=验证成功 8=注册成功 9=注册失败 10=验证中
 @xmppStream      XMPP流
 */
-(void)xmppServerConnectState:(int)state WithXMPPStream:(XMPPStream*)xmppStream;
// 用户上线
-(void)newBuddyOnline:(XMPPJID *)jid;
// 用户下线
-(void)buddyWentOffline:(XMPPJID *)jid;
/**
 收到添加好友请求
 @friendJID  请求的好友JID
 @subscription 请求的类型  subscribe=添加好友请求 subscribed=同意添加好友 unsubscribed=拒绝添加好友
 */
-(void)friendWhenSendAddAction:(XMPPJID*)friendJID Subscription:(NSString*)subscription;

/**
 收到用户消息
 @xmppMessage  收到消息内容
 @xmppStream   xmpp流
 */
-(void)didReceiveMessage:(XMPPMessage*)xmppMessage WithXMPPStream:(XMPPStream*)xmppStream andEMessage:(EMessages*)em;

/**
 收到我的好友数据
 每收到一个执行一次
 @friendJID  好友JID
 */
-(void)didReceiveMyFriends:(XMPPJID*)friendJID InGroup:(NSString*)groupName;

-(void)searchFriendsResult:(NSMutableArray*)data;


@end


@protocol XMPPServerDelegate <NSObject>

-(void)setupStream;
-(void)getOnline;
-(void)getOffline;

@end

@interface XMPPServer : NSObject<XMPPServerDelegate,XMPPRosterDelegate,XMPPvCardTempModuleDelegate,XMPPStreamDelegate>{
    XMPPStream *xmppStream;
    
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
    XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *password;
    BOOL isOpen;
    
}

@property (nonatomic, retain, readonly) XMPPStream *xmppStream;
@property (nonatomic, retain, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, retain, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, retain, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, retain, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, retain, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, retain, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, retain, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, assign) BOOL *isLogin;

@property (nonatomic, retain)  id<XMPPChatDelegate>       chatDelegate;

+(XMPPServer *)sharedServer;

-(BOOL)connect;

-(void)disconnect;

@end
