//
//  ETalks.h
//  DFMMessage
//
//  Created by dangfm on 14-5-26.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETalks : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * face;
@property (nonatomic, assign) double time;
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * myJID;

@end
