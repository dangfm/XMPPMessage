//
//  XMPPServer+Add.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPServer+Add.h"

@implementation XMPPServer (Add)

+(XMPPStream *)xmppStream{
    return [self sharedServer].xmppStream;
}

+(XMPPReconnect *)xmppReconnect{
    return [self sharedServer].xmppReconnect;
}

+(XMPPRoster *)xmppRoster{
    return [self sharedServer].xmppRoster;
}

+(XMPPRosterCoreDataStorage *)xmppRosterStorage{
    return [self sharedServer].xmppRosterStorage;
}

+(XMPPvCardTempModule *)xmppvCardTempModule{
    return [self sharedServer].xmppvCardTempModule;
}

+(XMPPvCardAvatarModule *)xmppvCardAvatarModule{
    return [self sharedServer].xmppvCardAvatarModule;
}

+(XMPPCapabilities *)xmppCapabilities{
    return [self sharedServer].xmppCapabilities;
}

+(XMPPCapabilitiesCoreDataStorage *)xmppCapabilitiesStorage{
    return [self sharedServer].xmppCapabilitiesStorage;
}

@end
