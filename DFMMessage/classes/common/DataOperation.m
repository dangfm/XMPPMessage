//
//  DataOperation.m
//  DFMMessage
//
//  Created by dangfm on 14-5-26.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "DataOperation.h"
#import <CoreData/CoreData.h>

@interface DataOperation(){
    
}

@end

static NSManagedObjectContext *_context;
static NSManagedObjectModel *_model;
static int _pageSize = 10;

@implementation DataOperation

+(NSManagedObjectModel*)instance{
    if (!_model) {
        // 从应用程序包中加载模型文件
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // 传入模型对象，初始化NSPersistentStoreCoordinator
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        // 构建SQLite数据库文件的路径
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        docs = [docs stringByAppendingPathComponent:@"dbs"];
        NSFileManager *file = [[NSFileManager alloc] init];
        BOOL yes = YES;
        if (![file fileExistsAtPath:docs isDirectory:&yes]) {
            [file createDirectoryAtPath:docs withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"UserModel.data"]];
        // 添加持久化存储库，这里使用SQLite作为存储库
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
        if (store == nil) { // 直接抛异常
            NSLog(@"删除重来");
            [file removeItemAtPath:[docs stringByAppendingPathComponent:@"UserModel.data"] error:nil];
            _model = nil;
            [self instance];
            return nil;
            [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
            
        }else{
            NSLog(@"%@",url);
        }
        
        // 初始化上下文，设置persistentStoreCoordinator属性
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = psc;
        _context = context;
        context = nil;
        _model = model;
        model = nil;
    }
    return _model;
}


+(void)addUsingBlock:(dataBlock)block{
    [DataOperation instance];
    [_context lock];
    // 传入上下文，创建一个Person实体对象
    if (block){
        block(_context);
    }
    [_context unlock];
}


+(NSArray*)select:(NSString*)tableName Where:(NSString*)where orderBy:(NSString*)orderName sortType:(BOOL)asc{
    [DataOperation instance];
    [_context lock];
    // 初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置要查询的实体
    request.entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:_context];
    if (orderName) {
        // 设置排序（按照age降序）
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:orderName ascending:asc];
        request.sortDescriptors = [NSArray arrayWithObject:sort];
        sort = nil;
    }
    
    // 设置条件过滤(搜索name中包含字符串"Itcast-1"的记录，注意：设置条件过滤时，数据库SQL语句中的%要用*来代替，所以%Itcast-1%应该写成*Itcast-1*)
    if (where) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:where];
        request.predicate = predicate;
        predicate = nil;
    }
    // 执行请求
    NSError *error = nil;
    NSArray *objs = [_context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
        return nil;
    }
    request = nil;
    [_context unlock];
    return objs;
}

+(NSArray*)selectWithPage:(int)page TableName:(NSString*)tableName Where:(NSString*)where orderBy:(NSString*)orderName sortType:(BOOL)asc andPageSize:(int)pageSize{
    [DataOperation instance];
    [_context lock];
    // 初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置要查询的实体
    request.entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:_context];
    if (orderName) {
        // 设置排序（按照age降序）
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:orderName ascending:asc];
        request.sortDescriptors = [NSArray arrayWithObject:sort];
        sort = nil;
    }
    
    // 设置条件过滤(搜索name中包含字符串"Itcast-1"的记录，注意：设置条件过滤时，数据库SQL语句中的%要用*来代替，所以%Itcast-1%应该写成*Itcast-1*)
    if (where) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:where];
        request.predicate = predicate;
        predicate = nil;
    }
    
    // 分页
    if (pageSize<=0) {
        pageSize = 1;
    }
    if (page<=0) {
        page = 1;
    }
    [request setFetchBatchSize:pageSize];
    [request setFetchOffset:(page-1)*pageSize];
    [request setFetchLimit:pageSize];
    
    // 执行请求
    NSError *error = nil;
    NSArray *objs = [_context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
        return nil;
    }
    request = nil;
    // 遍历数据
    //    for (NSManagedObject *obj in objs) {
    //        NSLog(@"name=%@", [obj valueForKey:@"userName"]);
    //    }
    [_context unlock];
    return objs;
}

+(int)deleteWithManagedObject:(NSManagedObject*)model{
    [_context lock];
    // 传入需要删除的实体对象(NSManageObject)
    [_context deleteObject:model];
    int i = [self save];
    [_context unlock];
    return i;
}

+(int)deleteTable:(NSString*)tableName{
    [_context lock];
    // 传入需要删除的实体对象(NSManageObject)
    NSArray *tableArray = [DataOperation select:tableName Where:nil orderBy:nil sortType:NO];
    for (NSManagedObject *object in tableArray) {
        [_context deleteObject:object];
    }
    int i = [self save];
    [_context unlock];
    return i;
}

+(int)save{
    // 将结果同步到数据库
    NSError *error = nil;
    [_context save:&error];
    if (error) {
        [NSException raise:@"错误" format:@"%@", [error localizedDescription]];
        return 0;
    }
    return 1;
}
@end
