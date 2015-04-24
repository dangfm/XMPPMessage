//
//  EMessages.h
//  DFMMessage
//
//  Created by 21tech on 14-5-27.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EMessages : NSManagedObject

@property (nonatomic, retain) NSString * guid;          // 标识
@property (nonatomic, retain) NSString * send_jid;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, assign) double time;
@property (nonatomic, assign) int messageType;          //0自己  1别人
@property (nonatomic, retain) NSString * receive_jid;
@property (nonatomic, assign) double second;
@property (nonatomic, retain) NSString * myJID;
@property (nonatomic, assign) BOOL isRead;              // 是否已读 1=已读
@property (nonatomic, assign) BOOL isSend;              // 是否已发送

@end
