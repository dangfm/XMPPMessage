//
//  DataOperation.h
//  DFMMessage
//
//  Created by dangfm on 14-5-26.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^dataBlock)(NSManagedObjectContext *context);

@interface DataOperation : NSObject

@property (nonatomic,retain) NSManagedObjectModel *model;
@property (nonatomic,retain) NSManagedObjectContext *context;
/**
 初始化（静态）
 */
+(NSManagedObjectModel*)instance;
/**
 添加数据
 @param block 通常写添加对象过程
 */
+(void)addUsingBlock:(dataBlock)block;
/**
 查询数据
 @param tableName 表名
 @param where 查询条件
 @param orderName 排序字段
 @param asc 升降序  YES=升序 NO=降序
 @return 返回一个对象集合 NSManageObjectModel
 */
+(NSArray*)select:(NSString*)tableName Where:(NSString*)where orderBy:(NSString*)orderName sortType:(BOOL)asc;
/**
 分页查询数据
 @param page 当前页
 @param pageSize 分页大小
 @return 返回分页后的对象集合 NSManageObjectModel
 */
+(NSArray*)selectWithPage:(int)page TableName:(NSString*)tableName Where:(NSString*)where orderBy:(NSString*)orderName sortType:(BOOL)asc andPageSize:(int)pageSize;
/**
 删除对象
 通常通过select方法查询得到对象后直接作为参数执行删除
 */
+(int)deleteWithManagedObject:(NSManagedObject*)model;

/**
 删除某个表
 循环删除的方式，效率有点低
 */
+(int)deleteTable:(NSString*)tableName;

/**
 保存当前操作到数据库，持久化操作
 */
+(int)save;
@end
