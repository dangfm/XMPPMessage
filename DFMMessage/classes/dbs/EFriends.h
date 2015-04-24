//
//  EFriends.h
//  DFMMessage
//
//  Created by 21tech on 14-5-27.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EFriends : NSManagedObject

@property (nonatomic, retain) NSString * firstChar;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * myJID;
@property (nonatomic, assign) BOOL isDelete;

@end
