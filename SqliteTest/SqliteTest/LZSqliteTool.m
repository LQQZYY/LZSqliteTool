//
//  LZSqliteTool.m
//  AccountManager
//
//  Created by Artron_LQQ on 16/4/18.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import "LZSqliteTool.h"
#import "FMDB.h"

static FMDatabase *LZ_db = nil;
static NSString *LZ_dbPath = nil;
static NSString *LZ_tableName = nil;

@implementation LZSqliteTool

+ (BOOL)createSqliteWithName:(NSString*)sqliteName {
    NSString *fileName = nil;
    NSArray *strArr = [sqliteName componentsSeparatedByString:@"."];
    if ([[strArr lastObject] isEqualToString:@"sqlite"]) {
        fileName = sqliteName;
    } else {
        fileName = [NSString stringWithFormat:@"%@.sqlite",sqliteName];
    }
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]];
    NSLog(@"%@",path);
    LZ_dbPath = path;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path]) {
        
      return [manager createFileAtPath:path contents:nil attributes:nil];
    }
    
    return YES;
}
+ (FMDatabase*)defaultDataBase {
    static dispatch_once_t onceToken;
    if (LZ_dbPath == nil) {
        [self createSqliteWithName:@"myDataBase"];
    }
    
    dispatch_once(&onceToken, ^{
        LZ_db = [[FMDatabase alloc]initWithPath:LZ_dbPath];
    });
    
    return LZ_db;
}

//创建表格
+ (void)createTableWithName:(NSString*)tableName {
    if (![LZ_db open]) {
        [LZ_db close];
        return;
    }
    //为数据设置缓存,提高查询效率
    [LZ_db setShouldCacheStatements:YES];
    if (![LZ_db tableExists:tableName]) {
        NSString *createTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'(accountID INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,identifier TEXT UNIQUE NOT NULL,nickName TEXT,userName TEXT,password TEXT,urlString TEXT,dsc TEXT)",tableName];
        [LZ_db executeUpdate:createTable];
    }
    
    LZ_tableName = tableName;
    [LZ_db close];
}

+ (void)changeTableName:(NSString*)tableName {
    LZ_tableName = tableName;
}

//删除表
+ (void)deleteTableWithName:(NSString*)tableName {
    if (![LZ_db open]) {
        [LZ_db close];
        
        return;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:tableName]) {
        NSString *dropTable = [NSString stringWithFormat:@"DROP TABLE '%@'",tableName];
        [LZ_db executeUpdate:dropTable];
    }
    
    [LZ_db close];
}

//为表添加元素
+ (void)alterElementName:(NSString*)element {
    if (![LZ_db open]) {
        [LZ_db close];
        
        return;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
        NSString *alter = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD '%@' TEXT",LZ_tableName,element];
        
        [LZ_db executeUpdate:alter];
    }
    
    [LZ_db close];
}

+ (void)updateWithModel:(LZDataModel*)model {
    if (![LZ_db open]) {
        [LZ_db close];
        
        return;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
        NSString *update = [NSString stringWithFormat:@"UPDATE '%@' SET userName = '%@',password = '%@' WHERE identifier = '%@'",LZ_tableName,model.userName,model.password,model.identifier];
        
        [LZ_db executeUpdate:update];
//        [LZ_db executeUpdate:@"UPDATE ? SET userName=?,password = ? WHERE identifier = ?",tableName,model.userName,model.password,model.identifier];
//        [LZ_db executeQueryWithFormat:@"UPDATE %@ SET userName = %@,password = %@ WHERE identifier = %@",tableName,model.userName,model.password,model.identifier];
    }
    
    [LZ_db close];
}

+ (void)insertWithModel:(LZDataModel*)model {
    if (![LZ_db open]) {
        [LZ_db close];
        return;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
//        @"INSERT INTO %@ VALUES (%@,%@,%@,%@,%@)" 顺序需和表一致
        NSString *insert = [NSString stringWithFormat:@"INSERT INTO '%@' (identifier,nickName,userName,password,urlString,dsc) VALUES ('%@','%@','%@','%@','%@','%@')",LZ_tableName,model.identifier,model.nickName,model.userName,model.password,model.urlString,model.dsc];
        
        [LZ_db executeUpdate:insert];
    }
    
    [LZ_db close];
}

+ (void)insertWithModel:(LZDataModel*)model useDataBaseQueue:(NSString*)queueName  {
    FMDatabaseQueue *baseQueue = [FMDatabaseQueue databaseQueueWithPath:LZ_dbPath];
    dispatch_queue_t queue = dispatch_queue_create([queueName UTF8String], NULL);
    dispatch_async(queue, ^{
        [baseQueue inDatabase:^(FMDatabase *db) {
            if ([db open]) {
                [db setShouldCacheStatements:YES];
                if ([db tableExists:LZ_tableName]) {
                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO '%@' (identifier,nickName,userName,password,urlString,dsc) VALUES ('%@','%@','%@','%@','%@','%@')",LZ_tableName,model.identifier,model.nickName,model.userName,model.password,model.urlString,model.dsc];
                    
                    [db executeUpdate:insert];
                }
            }
            NSLog(@"%@",[NSThread currentThread]);
            [db close];
        }];
    });
}

+(NSArray*)selectAllElements {
    if (![LZ_db open]) {
        [LZ_db close];
        return nil;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
        NSString *select = [NSString stringWithFormat:@"SELECT * FROM '%@'",LZ_tableName];
        FMResultSet *fs = [LZ_db executeQuery:select];
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
        
        while ([fs next]) {
            LZDataModel *model = [[LZDataModel alloc]init];
            model.identifier = [fs stringForColumn:@"identifier"];
            model.nickName = [fs stringForColumn:@"nickName"];
            model.userName = [fs stringForColumn:@"userName"];
            model.password = [fs stringForColumn:@"password"];
            model.urlString = [fs stringForColumn:@"urlString"];
            model.dsc = [fs stringForColumn:@"dsc"];
            
            [resultArray addObject:model];
        }
        
        [fs close];
        [LZ_db close];
        
        return resultArray;
    }
    
    return nil;
}

+ (NSArray*)selectPartElementsInRange:(NSRange)range {
    if (![LZ_db open]) {
        [LZ_db close];
        
        return nil;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
        NSString *select = [NSString stringWithFormat:@"SELECT * FROM '%@' LIMIT %lu,%lu",LZ_tableName,(unsigned long)range.location,(unsigned long)range.length];
        
        FMResultSet *fs = [LZ_db executeQuery:select];
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
        
        while ([fs next]) {
            LZDataModel *model = [[LZDataModel alloc]init];
            
            model.identifier = [fs stringForColumn:@"identifier"];
            model.nickName = [fs stringForColumn:@"nickName"];
            model.userName = [fs stringForColumn:@"userName"];
            model.password = [fs stringForColumn:@"password"];
            model.urlString = [fs stringForColumn:@"urlString"];
            model.dsc = [fs stringForColumn:@"dsc"];
            
            [resultArray addObject:model];
        }
        
        [fs close];
        [LZ_db close];
        
        return resultArray;
    }
    
    return nil;
}

+ (NSInteger)selectElementCount {
    if (![LZ_db open]) {
        [LZ_db close];
        
        return 0;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
        NSString *select = [NSString stringWithFormat:@"SELECT count(*) FROM '%@'",LZ_tableName];
        FMResultSet *fs = [LZ_db executeQuery:select];
        [fs next];
        NSInteger count = [fs intForColumn:@"count(*)"];
        
        [fs close];
        [LZ_db close];
        
        return count;
    }
    
    return 0;
}

+ (void)deleteElement:(LZDataModel*)model {
    if (![LZ_db open]) {
        [LZ_db close];
        
        return;
    }
    
    [LZ_db setShouldCacheStatements:YES];
    if ([LZ_db tableExists:LZ_tableName]) {
        NSString *delete = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE identifier = '%@'",LZ_tableName,model.identifier];
        [LZ_db executeUpdate:delete];
    }
    
    [LZ_db close];
}
@end
