//
//  ViewController.m
//  SqliteTest
//
//  Created by Artron_LQQ on 16/4/18.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import "ViewController.h"
#import "LZSqliteTool.h"
#import "LZDataModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [LZSqliteTool LZCreateSqliteWithName:@"accountData"];
    [LZSqliteTool LZDefaultDataBase];
    [LZSqliteTool LZCreateTableWithName:@"myAccount"];
    [LZSqliteTool LZCreateTableWithName:@"my"];
//    [LZSqliteTool LZDeleteTableWithName:@"myAccount"];
//    [LZSqliteTool LZAlterToTable:@"myAccount" elementName:@"COUNT"];
    for (int i = 0; i < 20; i++) {
        LZDataModel *model = [[LZDataModel alloc]init];
        model.identifier = [NSString stringWithFormat:@"aaaabbb%d",i];
        model.nickName = @"zszs";
        model.userName = @"lisi";
        model.password = @"123";
        model.dsc = @"eeeeeeeeeeeee";
        model.urlString = @"baidu";
        
//        [LZSqliteTool LZInsertTable:@"myAccount" model:model];
//        [LZSqliteTool LZDeleteElementFromTable:@"myAccount" element:model];
//        [LZSqliteTool LZInsertWithModel:model useDataBaseQueue:@"qq"];
        
    }
    
    
//    [LZSqliteTool LZInsertTable:@"myAccount" model:model];
    
//    [LZSqliteTool LZUpdateTable:@"myAccount" model:model];
    NSArray *ARR = [LZSqliteTool LZSelectAllElements];
    NSLog(@"%@",ARR);
    
    NSArray *arr = [LZSqliteTool LZSelectPartElementsInRange:NSMakeRange(2, 6)];
    NSLog(@"%@",arr);
    NSInteger COU = [LZSqliteTool LZSelectElementCount];
    NSLog(@"%ld",(long)COU);
    [LZSqliteTool LZChangeTableName:@"myAccount"];
     COU = [LZSqliteTool LZSelectElementCount];
    NSLog(@"%ld",(long)COU);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
