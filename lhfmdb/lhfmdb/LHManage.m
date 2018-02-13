//
//  LHManage.m
//  lhfmdb
//
//  Created by 刘辉 on 2017/8/24.
//  Copyright © 2017年 刘辉. All rights reserved.
//

#import "LHManage.h"
#import <objc/runtime.h>

@implementation LHManage
//全局变量
static id _instance = nil;
//单例方法
+(instancetype)sharedLH{
    return [[self alloc] init];
}
////alloc会调用allocWithZone:
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //只进行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
//初始化方法
- (instancetype)init{
    // 只进行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
}
//copy在底层 会调用copyWithZone:
- (id)copyWithZone:(NSZone *)zone{
    return  _instance;
}
+ (id)copyWithZone:(struct _NSZone *)zone{
    return  _instance;
}
+ (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return _instance;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}
/**
 根据一个类创建一个表且指定一个PRIMARYKEY(PRIMARYKEY必须为当前类的某一个属性名)
 */
- (BOOL)initLHDBWithPRIMARYKEY:(NSString*)PRIMARYKEY forClass:(Class)modleClass{
    NSString * tableName = [self getModelName:modleClass];
    if(!self.db) {
        [self creatTable];
    }
    if([self.db open]&& [self.db tableExists:tableName]) {
        //return self; //返回self 只是为了调完此方法后 还可以调其他方法 把固定的方法宏定义 更好的使用
    }
    //一般建的表是为了存model, 表中字段为model的属性, 唯一标识此条model数据的字段(id)设为主键
    if([self.db open]) {
        //遍历模型属性
        NSArray * arrayPro =  [self allPropertyNamesWithClass:[self getModelName:modleClass]];
        if ([arrayPro containsObject:PRIMARYKEY]) {
            NSMutableString * operate = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];
            [operate appendString:[NSString stringWithFormat:@"'%@' (",tableName]];
            for (NSString * strPro in arrayPro) {
                [operate appendString:[NSString stringWithFormat:@" '%@' TEXT,",strPro]];
            }
            [operate appendString:[NSString stringWithFormat:@" PRIMARY KEY('%@'));",PRIMARYKEY]];
            NSString* creatLHSql = operate;
            if(![self dbexecuteUpdate:creatLHSql]) {
                NSLog(@"初始化表失败....");
                return NO;
            }else{
                return YES;
            }
        }else{
            NSLog(@"PRIMARYKEY在此类的属性找不到!");
            return NO;
        }
    }else{
        return NO;
    }
}
/**
 获取当前表的PRIMARYKEY
 */
- (NSString*)getCurrentTablePRIMARYKEY:(NSString*)tableName{
    NSString * strPRIMARYKEY = nil;
    FMResultSet * res =  [self.db getTableSchema:tableName];
    while ([res next]) {
        int column = [res intForColumn:@"pk"];
        if (column) {
            strPRIMARYKEY = [res stringForColumn:@"name"];
        }
    }
    return strPRIMARYKEY;
}
/**
 对象转对象名字符串
 */
- (NSString*)getModelName:(id)model{
    NSString * tableName = NSStringFromClass([model class]);
    return tableName;
}
///通过运行时获取当前对象的所有属性的名称，以数组的形式返回
- (NSArray *) allPropertyNamesWithClass:(NSString*)class{
    //字符串转类🌟🌟🌟🌟🌟
    Class someClass = NSClassFromString(class);
    id obj = [[someClass alloc] init];
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    ///存储属性的个数
    unsigned int propertyCount = 0;
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([obj class], &propertyCount);
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    ///释放
    free(propertys);
    return allNames;
}
- (BOOL)dbexecuteUpdate:(NSString*)content{
    return [self.db executeUpdate:content];
}
- (void)creatTable{
    NSString* docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)firstObject];
    self.dbPath= [docuPath stringByAppendingPathComponent:@"lhTable.db"];
    _db= [FMDatabase databaseWithPath:self.dbPath];
    _dbQueue= [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    NSLog(@"db path ===== %@",self.dbPath);
}
/**
 添加一个模型
 */
- (void)addGoods:(id)model{
    NSString * tableName = [self getModelName:model];
    if (!model) {
        return;
    }
    //事务
//    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        //遍历模型属性
        NSArray * arrayPro =  [self allPropertyNamesWithClass:[NSString stringWithFormat:@"%@",[self getModelName:model]]];
        NSMutableString * operate = [[NSMutableString alloc]initWithString:@"INSERT OR REPLACE INTO "];
        [operate appendString:[NSString stringWithFormat:@"%@ (",tableName]];
        NSMutableString *keyStr = [[NSMutableString alloc]init];
        NSMutableString *valueStr = [[NSMutableString alloc]initWithString:@") VALUES ("];
        for (int i = 0; i<arrayPro.count; i++) {
            NSString * key = arrayPro[i];
            NSString * value = [model valueForKey:key];
            if (i == arrayPro.count-1) {
                [keyStr appendString:[NSString stringWithFormat:@"%@",key]];
                [valueStr appendString:[NSString stringWithFormat:@"'%@'",value]];
            }else{
                [keyStr appendString:[NSString stringWithFormat:@"%@,",key]];
                [valueStr appendString:[NSString stringWithFormat:@"'%@',",value]];
            }
        }
        [valueStr appendString:@")"];
        [operate appendString:keyStr];
        [operate appendString:valueStr];
        BOOL a = [self.db executeUpdate:operate];
        if (a) {
            NSLog(@"插入成功");
            return;
        }else{
            NSLog(@"插入失败");
//            *rollback = YES;
            return;
        }
//    }];
}
/**
 修改模型的一个字段(目前只支持单个表的单个字段的修改)
 */
- (BOOL)updateGoodsWithModelClass:(Class)modelClass withPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withKey:(NSString*)key withValue:(NSString*)value{
    NSString * tableName = [self getModelName:modelClass];
    if (!modelClass) {
        return NO;
    }
    NSString * PRIMARYKEY = [self getCurrentTablePRIMARYKEY:tableName];
    NSString *updateSql = [NSString stringWithFormat:
                           @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@'",
                           tableName,key,value,PRIMARYKEY,PRIMARYKEYValue];
    BOOL res = [self.db executeUpdate:updateSql];
    if (!res) {
        NSLog(@"更新失败");
        return NO;
    } else {
        NSLog(@"更新成功");
        return YES;
    }
}
/**
 查询表的所有模型
 */
- (NSArray*)searchAllModelWithModle:(Class)model{
    NSString * tableName = [self getModelName:model];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSString * operate = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    FMResultSet *res = [_db executeQuery:operate];
    while ([res next]) {
        id obj = [[model alloc] init];
        int i;
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList([obj class], &propertyCount);
        for ( i=0; i < propertyCount; i++ ) {
            objc_property_t *thisProperty = propertyList + i;
            const char* propertyName = property_getName(*thisProperty);
            NSString *key = [NSString stringWithUTF8String:propertyName];
            [obj setValue:[res stringForColumn:key] forKey:key];
        }
        // 记得释放
        free(propertyList);
        [dataArray addObject:obj];
    }
    return dataArray;
}
/**
 查询单个字段
 */
- (id)searchAProWithPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withKey:(NSString*)key withModelClass:(Class)modelClass{
    NSString * tableName = [self getModelName:modelClass];
    NSString * str ;
    NSString * PRIMARYKEY = [self getCurrentTablePRIMARYKEY:tableName];
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@'",key,tableName,PRIMARYKEY,PRIMARYKEYValue];
    FMResultSet *res = [_db executeQuery:query];
    while ([res next]) {
        str = [res stringForColumn:key];
    }
    return str;
}
/**
 插入一个列
 */
/**
 删除某个记录
 */
- (BOOL)deleteAElementWithPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withModelClass:(Class)modelClass{
    NSString * tableName = [self getModelName:modelClass];
    NSString * PRIMARYKEY = [self getCurrentTablePRIMARYKEY:tableName];
    NSString *deleteData = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",tableName,PRIMARYKEY,PRIMARYKEYValue];
    //开始一直没有删除成功， 原因是 把数据库的 名字写成了表的名字了
    BOOL success = [self.db executeUpdate:deleteData];
    return success;
}
/**
 删除数据库
 */
- (BOOL)deleteTableWithModleClass:(Class)modelClass{
    NSString * tableName = [self getModelName:modelClass];
    NSString *s = @"DROP TABLE IF EXISTS ";
    NSString * operate = [s stringByAppendingString:tableName];
    BOOL success =  [self.db executeUpdate:operate];
    [self.db close];
    return success;
}

@end
