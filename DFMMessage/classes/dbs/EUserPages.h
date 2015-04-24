//
//  EUserPages.h
//  DFMMessage
//
//  Created by 21tech on 14-6-25.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EUserPages : NSManagedObject

@property (nonatomic, retain) NSString * myJID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * photos;
@property (nonatomic, assign) double time;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, retain) NSString * friends_jid;

@end
