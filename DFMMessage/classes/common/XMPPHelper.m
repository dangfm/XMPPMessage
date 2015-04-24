//
//  XMPPHelper.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPHelper.h"
#import "EGOCache.h"
#import "EGOImageView.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"

@implementation XMPPHelper

+(void)sendVCardIQ{
    if ([XMPPServer sharedServer].isLogin) {
        XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
        [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@/%@",[CommonOperation getMyJID],kROSTER]];
        [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%f",[CommonOperation getTimestamp]]];
        NSXMLElement *vElement = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
        [iq addChild:vElement];
        // 通过xmppStream发送请求，重新下载vcard：
        [[XMPPServer sharedServer].xmppStream sendElement:iq];
    }
}


//获取头像
+(UIImage *)xmppUserPhotoForJID:(XMPPJID *)jid
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
    UIImage *img;
    NSData *photoData = [[[XMPPServer sharedServer] xmppvCardAvatarModule] photoDataForJID:jid];
    img = [UIImage imageWithData:photoData];
    photoData = nil;
    
    if (img==nil) {
        img = [UIImage imageNamed:@"noface"];
    }
    return img;
}

+(EMe*)my{
    EMe *me;
    NSArray *array = [DataOperation select:@"EMe" Where:[NSString stringWithFormat:@"jid='%@'",[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    if (array.count>0) {
        me = [array firstObject];
    }
    array = nil;
    
    return me;
}

#pragma mark ---注册用户---

+(void)checkRegisterFields{
    NSString *searchRegisterString = @"<iq type='get' id='reg1'><query xmlns='jabber:iq:register'/></iq>";
    NSXMLElement *sR = [[NSXMLElement alloc] initWithXMLString:searchRegisterString error:nil];
    // 查询注册
    [[XMPPServer sharedServer].xmppStream sendElement:sR];
}

+(void)registerWithUserName:(NSString*)userName Pass:(NSString*)pass{

    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    userName = [userName stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [[XMPPServer sharedServer].xmppStream setMyJID:[XMPPJID jidWithUser:userName domain:kHostName resource:kROSTER]];
    NSError *errPtr;
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:userName]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:pass]];
    [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:userName]];
    [[XMPPServer sharedServer].xmppStream registerWithElements:elements error:&errPtr];
    if (errPtr) {
        NSLog(@"%@",errPtr);
    }
    
}

/**
 <iq type='set' to='shakespeare.lit' id='change1'>
 <query xmlns='jabber:iq:register'>
 <username>bill</username>
 <password>newpass</password>
 </query>
 </iq>
 */
+(void)updatePassword:(NSString*)pass Nick:(NSString*)nick Email:(NSString*)email{
if ([XMPPServer sharedServer].isLogin) {
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%f",[CommonOperation getTimestamp]]];
    [iq addAttributeWithName:@"to" stringValue:kServerName];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    [queryElement addChild:[NSXMLElement elementWithName:@"username" stringValue:[XMPPServer sharedServer].xmppStream.myJID.user]];
    [queryElement addChild:[NSXMLElement elementWithName:@"password" stringValue:pass]];
    if (nick.length>0) {
        [queryElement addChild:[NSXMLElement elementWithName:@"name" stringValue:nick]];
    }
    if (email.length>0) {
        [queryElement addChild:[NSXMLElement elementWithName:@"email" stringValue:email]];
    }
    
    [iq addChild:queryElement];
    // 发送
    [[XMPPServer xmppStream] sendElement:iq];
}
}


+(NSXMLElement*)addFieldWithType:(NSString*)type Var:(NSString*)var Label:(NSString*)label Value:(NSString*)value{
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    if (type.length>0) {
        [field addAttributeWithName:@"type" stringValue:type];
    }
    
    if (label.length>0) {
        [field addAttributeWithName:@"label" stringValue:label];
    }
    if (var.length>0) {
        [field addAttributeWithName:@"var" stringValue:var];
    }
    
    NSXMLElement *valueXml = [NSXMLElement elementWithName:@"value" stringValue:value];
    [field addChild:valueXml];
    valueXml = nil;
    return field;
    
}


#pragma mark -------搜索用户---------

+(void)checkSearchUser{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:[XMPPServer sharedServer].xmppStream.myJID.bare];
    [iq addAttributeWithName:@"to" stringValue:@"search.dashixiong.cn"];
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%f",[CommonOperation getTimestamp]]];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:search"];
    [iq addChild:query];
    // 发送
    [[XMPPServer xmppStream] sendElement:iq];
}

/**
 搜索用户
 <iq id="ouA83-35" to="search.192.168.30.223" type="set">
    <query xmlns="jabber:iq:search">
        <x type="submit" xmlns="jabber:x:data">
            <field type="hidden" var="FORM_TYPE">
                <value>jabber:iq:search</value>
            </field>
            <field type="text-single" var="search">
                <value>bbb</value>
            </field>
            <field type="boolean" var="Username">
                <value>1</value>
            </field>
            <field type="boolean" var="Name">
                <value>1</value>
            </field>
            <field type="boolean" var="Email" >
                <value>1</value>
            </field>
        </x>
    </query>
 </iq>
 
 */
+(void)searchServerUsersWithKeyword:(NSString*)key{
if ([XMPPServer sharedServer].isLogin) {
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:[XMPPServer sharedServer].xmppStream.myJID.bare];
    [iq addAttributeWithName:@"to" stringValue:@"search.dashixiong.cn"];
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%f",[CommonOperation getTimestamp]]];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:search"];
    
    // 添加搜索的字段
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    [x addChild:[self addFieldWithType:@"hidden" Var:@"FORM_TYPE" Label:nil Value:@"jabber:iq:search"]];
    [x addChild:[self addFieldWithType:@"text-single" Var:@"search" Label:nil Value:key]];
//    [x addChild:[self addFieldWithType:@"boolean" Var:@"Username" Label:nil Value:key]];
//    [x addChild:[self addFieldWithType:@"boolean" Var:@"Name" Label:nil Value:@"1"]];
    [x addChild:[self addFieldWithType:@"boolean" Var:@"Email" Label:nil Value:@"1"]];
    //[x addChild:[self addFieldWithType:nil Var:@"x-gender" Label:nil Value:key]];
    //[x addChild:[self addFieldWithType:@"boolean" Var:@"last" Label:nil Value:@"1"]];
    
    [query addChild:x];
    [iq addChild:query];
    // 通过xmppStream发送搜索用户请求：
    NSLog(@"%@",iq);
    [[XMPPServer sharedServer].xmppStream sendElement:iq];
}
}


+(void)setUserDefaultWithUserName:(NSString*)userName Pass:(NSString*)pass{
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    userName = [userName stringByReplacingOccurrencesOfString:@"+" withString:@""];
    // 保存用户信息
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:USERID];
    [defaults setObject:pass forKey:PASS];
    //保存
    [defaults synchronize];
}

+(void)updateVCardWithEMe:(EMe*)me{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XMPPvCardTemp *vcard = [XMPPvCardTemp vCardTemp];
        NSString *updateId = [NSString stringWithFormat:@"%f",[CommonOperation getTimestamp]];
        me.updateId = updateId;
        [vcard setNickname:me.nickName];
        [vcard setPhoto:[me.face base64DecodedData]];
        [self setKey:@"sex" WithValue:me.sex WithVCard:vcard];
        [self setKey:@"updateId" WithValue:me.updateId WithVCard:vcard];
        [self setKey:@"area" WithValue:me.area WithVCard:vcard];
        [self setKey:@"sign" WithValue:me.sign WithVCard:vcard];
        [self setKey:@"longitude" WithValue:[NSString stringWithFormat:@"%f",me.longitude] WithVCard:vcard];
        [self setKey:@"latitude" WithValue:[NSString stringWithFormat:@"%f",me.latitude] WithVCard:vcard];
        [self setKey:@"geoHash" WithValue:me.geoHash WithVCard:vcard];
        
        [[XMPPServer sharedServer].xmppvCardTempModule updateMyvCardTemp:vcard];
        vcard = nil;
    });
    
    
}

+(void)updateEMeWithVCard:(XMPPvCardTemp*)vCard{
    EMe *me = [XMPPHelper my];
    if (!me) {
        [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
            EMe *me = [NSEntityDescription insertNewObjectForEntityForName:@"EMe" inManagedObjectContext:context];
            me.jid = [XMPPServer sharedServer].xmppStream.myJID.bare;
            me.nickName = vCard.nickname;
            me.face = [vCard.photo base64Encoding];
            me.sex = [vCard elementForName:@"sex"].stringValue;
            me.area = [vCard elementForName:@"area"].stringValue;
            me.sign = [vCard elementForName:@"sign"].stringValue;
            me.longitude = [[vCard elementForName:@"longitude"].stringValue doubleValue];
            me.latitude = [[vCard elementForName:@"latitude"].stringValue doubleValue];
            me.geoHash = [vCard elementForName:@"geoHash"].stringValue;
            me.allInfo = [vCard elementForName:@"allInfo"].stringValue;
            me.updateId = [vCard elementForName:@"updateId"].stringValue;
            [DataOperation save];
            NSLog(@"添加名片");
            me = nil;
        }];
    }else{
        me.jid = [XMPPServer sharedServer].xmppStream.myJID.bare;
        me.nickName = vCard.nickname;
        me.face = [vCard.photo base64Encoding];
        me.sex = [vCard elementForName:@"sex"].stringValue;
        me.area = [vCard elementForName:@"area"].stringValue;
        me.sign = [vCard elementForName:@"sign"].stringValue;
        me.longitude = [[vCard elementForName:@"longitude"].stringValue doubleValue];
        me.latitude = [[vCard elementForName:@"latitude"].stringValue doubleValue];
        me.geoHash = [vCard elementForName:@"geoHash"].stringValue;
        me.allInfo = [vCard elementForName:@"allInfo"].stringValue;
        me.updateId = [vCard elementForName:@"updateId"].stringValue;
        [DataOperation save];
        NSLog(@"更新名片");
    }
}

+(void)updateUserInfo:(EMe*)me{
    // 更新本地信息
    me.isUpdateSuccess = NO;
    // 更新注册信息
    NSString *pass = [[NSUserDefaults standardUserDefaults] valueForKey:PASS];
    // 位置编码|性别|签名|精度,纬度
    if (me.sex.length<=0) {
        me.sex = @"";
    }
    if (me.sign.length<=0) {
        me.sign = @"";
    }
    me.sign = [me.sign stringByReplacingOccurrencesOfString:@"|" withString:@","];
    me.nickName = [me.nickName stringByReplacingOccurrencesOfString:@"|" withString:@","];
    NSString *userName = [XMPPJID jidWithString:me.jid].user;
    if (me.nickName.length<=0) {
        me.nickName = userName;
    }
    // GEO|性别|账号|昵称|签名|经纬度|最后登录时间
    NSString *allInfo = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%f,%f|%f",me.geoHash,me.sex,userName,me.nickName,me.sign,me.longitude,me.latitude,[CommonOperation getTimestamp]];
    me.allInfo = allInfo;
    [DataOperation save];
    [self updatePassword:pass Nick:me.nickName Email:allInfo];
    
}



+ (void)setKey:(NSString *)key WithValue:(NSString*)value WithVCard:(XMPPvCardTemp *)vCard {
	NSXMLElement *elem = [vCard elementForName:key];
    
	if (elem == nil) {
		elem = [NSXMLElement elementWithName:key];
		[vCard addChild:elem];
	}
	
	[elem setStringValue:value];
}
@end
