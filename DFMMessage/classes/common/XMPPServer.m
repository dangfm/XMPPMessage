//
//  XMPPServer.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPServer.h"
#import "XMPPPresence.h"
#import "XMPPJID.h"
#import "XMPPvCardTempBase.h"
#import "Statics.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import <AVFoundation/AVFoundation.h>

static XMPPServer *singleton = nil;
static NSOperationQueue *_XMPPQueue = nil;

@implementation XMPPServer

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize chatDelegate;

#pragma mark - singleton
+(XMPPServer *)sharedServer{
    @synchronized(self){
        if (singleton == nil) {
            _XMPPQueue = [[NSOperationQueue alloc] init];
            singleton = [[self alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

//-(id)retain{
//    return singleton;
//}
//
//-(oneway void)release{
//}

+(id)release{
    return nil;
}

//-(id)autorelease{
//    return singleton;
//}

-(void)dealloc{
     [self teardownStream];
    //[super dealloc];
}


#pragma mark - private
-(void)setupStream{
    if (!xmppStream) {
    // NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //[xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    	//[xmppStream setHostName:@"talk.google.com"];
//        [xmppStream setHostName:@"192.168.16.18"];
//    	[xmppStream setHostPort:5222];
    }
}

- (void)teardownStream
{
    [_XMPPQueue cancelAllOperations];
    _XMPPQueue = nil;
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

-(void)getOnline{

    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
    if ([chatDelegate respondsToSelector:@selector(newBuddyOnline:)]) {
        [chatDelegate newBuddyOnline:[xmppStream myJID]];
    }
    [XMPPHelper sendVCardIQ];
}


-(void)getOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

-(BOOL)connect{

    [self setupStream];
    //从本地取得用户名，密码和服务器地址
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:USERID];
    NSString *pass = [defaults stringForKey:PASS];
    // 默认匿名登录
    if (userId.length<=1) {
        userId = @"anonymous";
        pass = @"";
    }
    password = pass;
    
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    self.isLogin = NO;
    //设置用户：user1@dashixiong.cn/appname 格式的用户名
    XMPPJID *jid = [XMPPJID jidWithUser:userId domain:kHostName resource:kROSTER];
    [xmppStream setMyJID:jid];
    //设置服务器
    [xmppStream setHostName:kServerName];
    //连接服务器
    NSError *error = nil;
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:1 WithXMPPStream:xmppStream];
    }
    //    if ( ![xmppStream connect:&error]) {
    if (![xmppStream connectWithTimeout:10 error:&error]) {//新版本的xmpp
        if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
            [chatDelegate xmppServerConnectState:-1 WithXMPPStream:xmppStream];
        }
        return NO;
    }
    return YES;
}

//断开服务器连接
-(void)disconnect{
    [self getOffline];
    [xmppStream disconnect];
}

#pragma mark - XMPPStream delegate  
#pragma mark 连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    isOpen = YES;
    NSError *error = nil;
    NSLog(@"已连接");
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:2 WithXMPPStream:xmppStream];
    }
    //验证密码
    if (![sender.myJID.user isEqualToString:@"anonymous"]) {
        if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
            [chatDelegate xmppServerConnectState:10 WithXMPPStream:xmppStream];
        }
        [xmppStream authenticateWithPassword:password error:&error];
    }
    
}

#pragma mark 连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:4 WithXMPPStream:xmppStream];
    }
    // 五秒后继续连接
    [self performSelector:@selector(connect) withObject:nil afterDelay:10];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:-1 WithXMPPStream:xmppStream];
    }
    // 五秒后继续连接
    [self performSelector:@selector(connect) withObject:nil afterDelay:10];
}
#pragma mark 验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:7 WithXMPPStream:xmppStream];
    }
    self.isLogin = YES;
    //上线
    [self getOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    NSLog(@"验证错误");
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:5 WithXMPPStream:xmppStream];
    }
}


/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 *
 */

/*
 
 名册

 <iq xmlns="jabber:client" type="result" to="user2@chtekimacbook-pro.local/80f94d95">
     <query xmlns="jabber:iq:roster">
         <item jid="user6" name="" ask="subscribe" subscription="from"/>
         <item jid="user3@chtekimacbook-pro.local" name="bb" subscription="both">
            <group>好友</group><group>user2的群组1</group>
         </item>
         <item jid="user7" name="" ask="subscribe" subscription="from"/>
         <item jid="user7@chtekimacbook-pro.local" name="" subscription="both">
            <group>好友</group><group>user2的群组1</group>
         </item>
         <item jid="user1" name="" ask="subscribe" subscription="from"/>
     </query>
 </iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    //[_XMPPQueue addOperationWithBlock:^{
        NSString *myJID = [CommonOperation getMyJID];//当前用户
        //NSLog(@"didReceiveIQ--iq is:%@",iq.XMLString);
        
        if ([@"result" isEqualToString:iq.type]) {
            NSXMLElement *query = iq.childElement;
            if ([@"vCard" isEqualToString:query.name]) {
                XMPPvCardTemp *vCard = [XMPPvCardTemp vCardTempCopyFromIQ:iq];
                if ([[iq to].bare isEqualToString:sender.myJID.bare]) {
                    // 更新自己的名片
                    EMe *me = [XMPPHelper my];
                    if ([me.updateId isEqualToString:[[vCard elementForName:@"updateId"] stringValue]]) {
                        me.isUpdateSuccess = YES;
                        [DataOperation save];
                        NSLog(@"名片更新成功");
                    }
                    [XMPPHelper updateEMeWithVCard:vCard];
                    me = nil;
                }
                
                vCard = nil;
            }
            
            // 搜索结果
            if ([@"jabber:iq:search" isEqualToString:query.xmlns]) {
                NSLog(@"---搜索结果：%@",iq.XMLString);
                NSMutableArray *array = [[NSMutableArray alloc] init];
                NSXMLElement *x = [[query children] firstObject];
                NSArray *items = [x children];
                for (NSXMLElement *item in items) {
                    //搜索结果
                    UserModel *me = [[UserModel alloc] init];
                    if ([item.name isEqualToString:@"item"]) {
                        for (NSXMLElement *field in item.children) {
                            NSString *var = [field attributeStringValueForName:@"var"];
                            NSXMLElement *value = [field.children firstObject];
                            if ([var isEqualToString:@"Username"]) {
                                if (me.nickName.length<=0) {
                                    me.nickName = value.stringValue;
                                }
                                
                            }
                            if ([var isEqualToString:@"Name"]) {
                                if (value.stringValue.length>0) {
                                    me.nickName = value.stringValue;
                                }
                                
                            }
                            if ([var isEqualToString:@"Email"]) {
                                me.allInfo = value.stringValue;
                            }
                            if ([var isEqualToString:@"jid"]) {
                                me.jid = value.stringValue;
                            }
                        }
                        
                    }
                    if (me.jid) {
                        if (me.allInfo.length>0) {
                            // GEO|性别|账号|昵称|签名|经纬度|时间
                            NSArray *all = [me.allInfo componentsSeparatedByString:@"|"];
                            for (NSInteger i=0; i<all.count; i++) {
                                NSString *item = [all objectAtIndex:i];
                                switch (i) {
                                    case 0:
                                        me.geoHash = item;
                                        break;
                                    case 1:
                                        me.sex = item;
                                        break;
                                    case 3:
                                        me.nickName = item;
                                        break;
                                    case 4:
                                        me.sign = item;
                                        break;
                                    case 5:
                                        me.longitude = [[[item componentsSeparatedByString:@","] firstObject] doubleValue];
                                        me.latitude = [[[item componentsSeparatedByString:@","] lastObject] doubleValue];
                                        me.distance = [CommonOperation GetLocationDist:me.longitude other_Lat:me.latitude];
                                        break;
                                    case 6:
                                        me.time = [item doubleValue];
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                        
                        [array addObject:me];
                    }
                    me = nil;
                    
                }
                
                // 通知代理
                if ([chatDelegate respondsToSelector:@selector(searchFriendsResult:)]) {
                    [chatDelegate searchFriendsResult:array];
                }
            }
            
            if ([@"jabber:iq:roster" isEqualToString:query.xmlns]) {
                NSLog(@"didReceiveIQ--iq is:%@",iq.XMLString);
                NSArray *items = [query children];
                for (NSXMLElement *item in items) {
                    //订阅签署状态
                    NSString *subscription = [item attributeStringValueForName:@"subscription"];
                    NSString *jid = [item attributeStringValueForName:@"jid"];
                    NSString *nickName = [item attributeStringValueForName:@"name"];
                    NSString *userName = [[jid componentsSeparatedByString:@"@"] firstObject];
                    if ([subscription isEqualToString:@"both"]) {
                        
                        NSLog(@"user:%@ nickName:%@",userName,nickName);
                        [xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithString:jid] shouldFetch:YES];
                        // 查询是否存在
                        NSArray *users = [DataOperation select:@"EFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid,myJID] orderBy:nil sortType:YES];
                        if (users.count<=0) {
                            // 添加进朋友列表
                            [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
                                EFriends *friends = [NSEntityDescription insertNewObjectForEntityForName:@"EFriends" inManagedObjectContext:context];
                                friends.userName = userName;
                                friends.jid = jid;
                                friends.nickName = nickName.length>0?nickName:userName;
                                friends.note = userName;
                                friends.myJID = myJID;
                                friends.firstChar = [[[CommonOperation getPinyin:nickName.length>0?nickName:userName] substringToIndex:1] uppercaseString];
                                [DataOperation save];
                                friends = nil;
                            }];
                        }else{
                            // 更新
                            EFriends *f = [users firstObject];
                            f.nickName = nickName.length>0?nickName:userName;
                            f.firstChar = [[[CommonOperation getPinyin:nickName.length>0?nickName:userName] substringToIndex:1] uppercaseString];
                            [DataOperation save];
                            f = nil;
                        }
                        //群组：
                        NSArray *groups = [item elementsForName:@"group"];
                        for (NSXMLElement *groupElement in groups) {
                            NSString *groupName = groupElement.stringValue;
                            NSLog(@"didReceiveIQ----xmppJID:%@ , in group:%@",jid,groupName);
                            //  [[XMPPServer xmppRoster] addUser:xmppJID withNickname:@""];
                        }
                        users = nil;
                        groups = nil;
                        jid = nil;
                        nickName = nil;
                        userName = nil;
                    }
                    
                    else{
                        //from to
                    }
                    subscription = nil;
                }
            }
            
            //[query detach];
            query = nil;
        }
    //}];
    
    
    return YES;
}



#pragma mark Core Data
- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

/*
 收到消息
 
 <message
     to='romeo@example.net'
     from='juliet@example.com/balcony'
     type='chat'
     xml:lang='en'>
     <body>Wherefore art thou, Romeo?</body>
 </message>
 
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSLog(@"---message----%@",message.XMLString);
    NSString *myJID = [CommonOperation getMyJID];//当前用户
    if ([message isChatMessageWithBody])
	{
//		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
//		                                                         xmppStream:xmppStream
//		                                               managedObjectContext:[self managedObjectContext_roster]];
//        
//        
//		if (user==nil) {
//            return;
//        }
		NSString *body = [[message elementForName:@"body"] stringValue];
        XMPPJID *jid = [message from];
        NSString *jidStr = [NSString stringWithFormat:@"%@@%@",jid.user,jid.domain];
        NSArray *users = [DataOperation select:@"EFriends" Where:[NSString stringWithFormat:@"jid='%@'",jidStr] orderBy:nil sortType:YES];
        NSString *displayName;
        NSString *nickName;
        if (users.count>0) {
            EFriends *f = [users firstObject];
            if (f.nickName.length>0) {
                nickName = f.nickName;
            }
            f = nil;
        }
        if (nickName.length<1) {
            nickName = displayName;
        }
        
        users = nil;
        __block EMessages *e;
        // 存入消息
        [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
            
            e = [NSEntityDescription insertNewObjectForEntityForName:@"EMessages" inManagedObjectContext:context];
            e.send_jid = jidStr;
            e.receive_jid = myJID;
            e.content = body;
            e.time = [CommonOperation getTimestamp];
            e.myJID = [CommonOperation getMyJID];
            e.isRead = NO;
            e.messageType = 1;
            if ([body hasPrefix:@"base64"]) {
                NSData *data = [[body substringFromIndex:6] base64DecodedData];
                AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
                e.second = player.duration;
                player = nil;
                data = nil;
            }
            
        }];
        
        // 存档
        NSArray *result = [DataOperation select:@"ETalks" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jidStr,myJID] orderBy:nil sortType:YES];
        if (result.count>0) {
            // 更新
            ETalks *e = (ETalks*)[result firstObject];
            e.userName = nickName;
            e.content = [[message elementForName:@"body"] stringValue];
            e.time = [CommonOperation getTimestamp];
            e.myJID = myJID;
            [DataOperation save];
            e = nil;
        }else{
            // 添加
            [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
                ETalks *e = [NSEntityDescription insertNewObjectForEntityForName:@"ETalks" inManagedObjectContext:context];
                e.userName = nickName;
                e.content = [[message elementForName:@"body"] stringValue];
                e.time = [CommonOperation getTimestamp];
                e.jid = jidStr;
                e.face = jidStr;
                e.myJID = myJID;
                [DataOperation save];
                e = nil;
            }];
        }
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
            
            if ([chatDelegate respondsToSelector:@selector(didReceiveMessage:WithXMPPStream:andEMessage:)]) {
                [chatDelegate didReceiveMessage:message WithXMPPStream:sender andEMessage:e];
            }
            
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
        e = nil;
	}
}

/*
 
 收到好友状态
<presence xmlns="jabber:client" 
    from="user3@chtekimacbook-pro.local/ch&#x7684;MacBook Pro" 
    to="user2@chtekimacbook-pro.local/7b55e6b">
    <priority>0</priority>
    <c xmlns="http://jabber.org/protocol/caps" node="http://www.apple.com/ichat/caps" ver="900" ext="ice recauth rdserver maudio audio rdclient mvideo auxvideo rdmuxing avcap avavail video"/>
     <x xmlns="http://jabber.org/protocol/tune"/>
     <x xmlns="vcard-temp:x:update">
        <photo>E10C520E5AE956E659A0DBC5C7F48E12DF9BE6EB</photo>
     </x>
 </presence>
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //NSLog(@"didReceivePresence----%@",presence.XMLString);
    
    
    
    NSString *presenceType = [presence type]; //取得好友状态
    
    NSString *userId = [[sender myJID] user];//当前用户
    
    
    NSString *presenceFromUser = [[presence from] user];//在线用户
    NSLog(@"didReceivePresence---- presenceType:%@,用户:%@",presenceType,presenceFromUser);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            if (chatDelegate) {
                if ([chatDelegate respondsToSelector:@selector(newBuddyOnline:)]) {
                    [chatDelegate newBuddyOnline:[presence from]];//用户列表委托
                }
            }
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            if (chatDelegate) {
                if ([chatDelegate respondsToSelector:@selector(buddyWentOffline:)]) {
                    [chatDelegate buddyWentOffline:[presence from]];//用户列表委托
                }
            }
        }
        
        //这里再次加好友:如果请求的用户返回的是同意添加
        else if ([presenceType isEqualToString:@"subscribed"]) {
            // 保存用户进分组
            [CommonOperation saveFriendIntoGroupWithJid:presence.from.bare andNickName:presenceFromUser];
        }
        
        //用户拒绝添加好友
        else if ([presenceType isEqualToString:@"unsubscribed"]) {
            // 当用户拒绝添加为好友，订阅状态为unsubscribed
            // 用户点击拒绝按钮，会触发此事件
            // 删除分组里对应的朋友
            [xmppRoster removeUser:[presence from]];
            // 删除本地好友
            NSArray *array = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"jid='%@'",[presence from].bare] orderBy:nil sortType:NO];
            if (array.count>0) {
                EAddFriends *add = [array firstObject];
                add.subscription = @"none";
                add.myJID = [CommonOperation getMyJID];
                add.isDelete = YES;
                [DataOperation save];
                add = nil;
            }
            array = nil;
        }
        
        else if ([presenceType isEqualToString:@"subscribe"]) {
            // 用户上线后收到历史添加好友请求
            NSLog(@"请求添加好友");
            [CommonOperation saveAddFriendWithJid:presence.from.bare andNickName:presenceFromUser];

        }
        
        // 通知代理 用户收到好友状态
        if ([chatDelegate respondsToSelector:@selector(friendWhenSendAddAction:Subscription:)]) {
            [chatDelegate friendWhenSendAddAction:[presence from] Subscription:presenceType];
        }
    }
}

#pragma mark - XMPPRoster delegate
/**
 * Sent when a presence subscription request is received.
 * That is, another user has added you to their roster,
 * and is requesting permission to receive presence broadcasts that you send.
 *
 * The entire presence packet is provided for proper extensibility.
 * You can use [presence from] to get the JID of the user who sent the request.
 *
 * The methods acceptPresenceSubscriptionRequestFrom: and rejectPresenceSubscriptionRequestFrom: can
 * be used to respond to the request.
 *
 *  本人同意好友添加请求
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    
    NSLog(@"didReceivePresenceSubscriptionRequest----presenceType:%@,用户：%@,presence:%@",presenceType,presenceFromUser,presence);
    // 用户上线后收到历史添加好友请求
    NSLog(@"请求添加好友");
    // 是否是好友关系
    // 如果对方在线，则会返回both否则返回from
    if ([presenceType isEqualToString:@"both"]) {
        [CommonOperation saveFriendIntoGroupWithJid:presence.from.bare andNickName:presenceFromUser];
    }
    if ([presenceType isEqualToString:@"subscribe"]) {
        [CommonOperation saveAddFriendWithJid:presence.from.bare andNickName:presenceFromUser];
    }
    if ([presenceType isEqualToString:@"none"]) {
        [CommonOperation saveAddFriendWithJid:presence.from.bare andNickName:presenceFromUser];
    }
    if ([presenceType isEqualToString:@"remove"]) {
        [CommonOperation deleteFriendWithJid:presence.from.bare];
        
    }
    
    /*
     user1向登录账号user2请求加为好友：
     
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" to="user2@chtekimacbook-pro.local" type="subscribe" from="user1@chtekimacbook-pro.local"/>  
     sender2:<XMPPRoster: 0x7c41450>
     
     登录账号user2发起user1好友请求，user5
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" type="subscribe" to="user2@chtekimacbook-pro.local" from="user1@chtekimacbook-pro.local"/>  
     sender2:<XMPPRoster: 0x14ad2fb0>
     */
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 *  
 * 添加好友、好友确认、删除好友
 
 用户收到添加好友请求
 test用户向mm用户请求添加好友
 <iq xmlns="jabber:client" type="set" id="671-1804" to="mm@dashixiong.cn/jianghu"><query xmlns="jabber:iq:roster"><item jid="test@dashixiong.cn" subscription="from"/></query></iq>

 //用户6确认后：
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/662d302c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/></query></iq>
 
 //删除用户6：？？？
 <iq xmlns="jabber:client" type="set" id="592-372" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="from"/></query></iq>
  
 <iq xmlns="jabber:client" type="set" id="954-374" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="none"/></query></iq>

 <iq xmlns="jabber:client" type="set" id="965-376" to="user2@chtekimacbook-pro.local/e799ef0c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" subscription="remove"/></query></iq>
  */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    NSLog(@"didReceiveRosterPush:(XMPPIQ *)iq is :%@",iq.XMLString);
     NSXMLElement *query = iq.childElement;
    // 添加好友，删除好友
    if ([query.xmlns isEqualToString:@"jabber:iq:roster"]) {
        NSXMLElement *item = [query.children firstObject];
        NSString *subscription = [item attributeStringValueForName:@"subscription"];
        NSString *jid = [item attributeStringValueForName:@"jid"];
        NSString *ask = [item attributeStringValueForName:@"ask"];
        NSString *presenceFromUser = [XMPPJID jidWithString:jid].user;
        if ([subscription isEqualToString:@"remove"]) {
            [CommonOperation deleteFriendWithJid:jid];
        }
        if ([subscription isEqualToString:@"both"]) {
            [CommonOperation saveFriendIntoGroupWithJid:jid andNickName:presenceFromUser];
        }
        // 我接受添加好友
        if ([ask isEqualToString:@"subscribe"] && [subscription isEqualToString:@"from"]) {
            // 把好友添加进数据库 添加好友提示消除
            [CommonOperation saveFriendIntoGroupWithJid:jid andNickName:presenceFromUser];
            
        }
    }
    
}

/**
 * Sent when the initial roster is received.
 *
 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidBeginPopulating");
}

/**
 * Sent when the initial roster has been populated into storage.
 *
 */
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidEndPopulating");
}

/**
 * Sent when the roster recieves a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 *
 */
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item{
    
//    NSString *jid = [item attributeStringValueForName:@"jid"];
//    NSString *name = [item attributeStringValueForName:@"name"];
//    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    
//    DDXMLNode *node = [item childAtIndex:0];
//    node
//    NSXMLElement *groupElement = [item elementForName:@"group"];
//    NSString *group = [groupElement attributeStringValueForName:@"group"];
    
//    NSLog(@"didRecieveRosterItem:  jid=%@,name=%@,subscription=%@,group=%@",jid,name,subscription);
    
}
/**
 注册成功
 */
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:8 WithXMPPStream:xmppStream];
    }
}

/**
 注册失败
 */
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    if ([chatDelegate respondsToSelector:@selector(xmppServerConnectState:WithXMPPStream:)]) {
        [chatDelegate xmppServerConnectState:9 WithXMPPStream:xmppStream];
    }
}





@end
