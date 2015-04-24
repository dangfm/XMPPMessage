//
//  XMPPServer+Add.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPServer.h"

@interface XMPPServer (Add)

+(XMPPStream *)xmppStream;

+(XMPPReconnect *)xmppReconnect;

+(XMPPRoster *)xmppRoster;

+(XMPPRosterCoreDataStorage *)xmppRosterStorage;

+(XMPPvCardTempModule *)xmppvCardTempModule;

+(XMPPvCardAvatarModule *)xmppvCardAvatarModule;

+(XMPPCapabilities *)xmppCapabilities;

+(XMPPCapabilitiesCoreDataStorage *)xmppCapabilitiesStorage;

@end
