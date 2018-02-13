//
//  LHManage.h
//  lhfmdb
//
//  Created by 刘辉 on 2017/8/24.
//  Copyright © 2017年 刘辉. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <FMDB.h>
//成员变量的组成部分
#import"FMDatabase.h"
#import"FMDatabaseQueue.h"
#import"FMDatabaseAdditions.h"

@interface LHManage : NSObject

@property(nonatomic,retain)FMDatabase*db;
@property(nonatomic,retain)NSString*dbPath;
@property(nonatomic,retain)FMDatabaseQueue*dbQueue;

/**
 单例方法
 */
+(instancetype)sharedLH;
/**
 根据一个类创建一个表且指定一个PRIMARYKEY(PRIMARYKEY必须未当前类的某一个属性名)
 */
- (BOOL)initLHDBWithPRIMARYKEY:(NSString*)PRIMARYKEY forClass:(Class)modleClass;
/**
 添加一个模型
 */
- (void)addGoods:(id)model;
/**
 修改模型的一个字段(目前只支持单个表的单个字段的修改)
 */
- (BOOL)updateGoodsWithModelClass:(Class)modelClass withPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withKey:(NSString*)key withValue:(NSString*)value;
/**
 查询所有模型
 */
- (NSArray*)searchAllModelWithModle:(Class)model;
/**
 查询单个字段
 */
- (id)searchAProWithPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withKey:(NSString*)key withModelClass:(Class)modelClass;
/**
 插入一个列
 */
/**
 删除某个记录
 */
- (BOOL)deleteAElementWithPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withModelClass:(Class)modelClass;
/**
 删除数据库
 */
- (BOOL)deleteTableWithModleClass:(Class)modelClass;

@end
