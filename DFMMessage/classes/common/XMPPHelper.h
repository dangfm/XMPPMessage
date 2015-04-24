//
//  XMPPHelper.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPHelper : NSObject

+(void)sendVCardIQ;

+(UIImage *)xmppUserPhotoForJID:(XMPPJID *)jid;

+(EMe*)my;

+(void)checkRegisterFields;
+(void)registerWithUserName:(NSString*)userName Pass:(NSString*)pass;
+(void)setUserDefaultWithUserName:(NSString*)userName Pass:(NSString*)pass;
+(void)updatePassword:(NSString*)pass Nick:(NSString*)nick Email:(NSString*)email;

#pragma mark 搜索用户
+(void)checkSearchUser;
+(void)searchServerUsersWithKeyword:(NSString*)key;

#pragma mark 用户名片
+(void)updateVCardWithEMe:(EMe*)me;
+(void)updateUserInfo:(EMe*)me;
+(void)updateEMeWithVCard:(XMPPvCardTemp*)vCard;
@end
