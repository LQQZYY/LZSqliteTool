//
//  LZSqliteTool.h
//  AccountManager
//
//  Created by Artron_LQQ on 16/4/18.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZDataModel.h"

@class FMDatabase;
@interface LZSqliteTool : NSObject

/**
*  @author LQQ, 16-04-18 17:04:28
*
*  创建一个数据库,保存在沙盒
*
*  @param sqliteName 数据库名,可加后缀(.sqlite),也可不加,方法内有判断
*
*  @return 返回是否创建成功
*/
+ (BOOL)LZCreateSqliteWithName:(NSString*)sqliteName;

/**
 *  @author LQQ, 16-04-19 14:04:26
 *
 *  生成一个单例的数据库文件
 *
 *  @return 返回一个单例数据库
 */
+ (FMDatabase*)LZDefaultDataBase;

/**
 *  @author LQQ, 16-04-19 14:04:20
 *
 *  在数据库中创建一个表
 *
 *  @param tableName 创建的表名
 */
+ (void)LZCreateTableWithName:(NSString*)tableName;

/**
 *  @author LQQ, 16-04-19 20:04:29
 *
 *  切换操作的表(当数据库中需要对多个表操作时,可调用此方法切换操作的表)
 *
 *  @param tableName 切换的表名
 */
+ (void)LZChangeTableName:(NSString*)tableName;

/**
 *  @author LQQ, 16-04-19 14:04:54
 *
 *  删除表
 *
 *  @param tableName 需要删除的表名
 */
+ (void)LZDeleteTableWithName:(NSString*)tableName;

/**
 *  @author LQQ, 16-04-19 21:04:59
 *
 *  向表中添加一列元素
 *
 *  @param element 添加的列名
 */
+ (void)LZAlterElementName:(NSString*)element;

/**
 *  @author LQQ, 16-04-19 21:04:50
 *
 *  向表中添加一个数据
 *
 *  @param model 需要添加的数据模型
 */
+ (void)LZInsertWithModel:(LZDataModel*)model;

/**
 *  @author LQQ, 16-04-19 21:04:38
 *
 *  线程安全的插入数据
 *
 *  @param model 数据模型
 *  @param queueName 队列名称
 */
+ (void)LZInsertWithModel:(LZDataModel*)model useDataBaseQueue:(NSString*)queueName;

/**
 *  @author LQQ, 16-04-19 21:04:05
 *
 *  修改某条数据内容
 *
 *  @param model 需要修改的数据模型
 */
+ (void)LZUpdateWithModel:(LZDataModel*)model;

/**
 *  @author LQQ, 16-04-19 21:04:37
 *
 *  查询某个表中所有的数据
 *
 *  @return 含有所有数据模型的数组
 */
+ (NSArray*)LZSelectAllElements;

/**
 *  @author LQQ, 16-04-19 21:04:22
 *
 *  查询某一范围的数据
 *
 *  @param range 数据的范围
 *
 *  @return 返回含有数据模型的数组
 */
+ (NSArray*)LZSelectPartElementsInRange:(NSRange)range;

/**
 *  @author LQQ, 16-04-19 21:04:08
 *
 *  获取某张表里有多少条数据
 *
 *  @return 表里数据的数目
 */
+ (NSInteger)LZSelectElementCount;

/**
 *  @author LQQ, 16-04-19 21:04:50
 *
 *  删除表里某个元素
 *
 *  @param model 需要删除的数据模型
 */
+ (void)LZDeleteElement:(LZDataModel*)model;
@end
