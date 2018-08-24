//
//  ViewController.m
//  lhfmdb
//
//  Created by 管理员 on 2017/8/24.
//  Copyright © 2017年 刘辉. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) GoodsModel * goods;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    //建一个对象
    [self createAGoods];
    
    //建表并指定一个PRIMARYKEY
    if ([[LHManage sharedLH]initLHDBWithPRIMARYKEY:@"ID" forClass:[GoodsModel class]]) {
        //添加数据
        [self addGoods:self.goods];
        
        //查询数据并打印(所有)
        [self searchAllModel];
        NSLog(@"-------------- old ----------------");
        //查询数据并打印(根据指定的PRIMARYKEY的值找到指定要查的字段的值)
        [self searchAValueP:self.goods.ID withKey:@"imageUrl"];
        
        //修改表数据的其中一个字段
        [self updateAValueDataWithPRIMARYKEYValue:self.goods.ID withKey:@"link" withValue:@"http://www.google.com"];
        
        //删除表
//        [[LHManage sharedLH]deleteTableWithModleClass:[GoodsModel class]];

    }else{
        NSLog(@"建表失败");
    }
}
- (void)createAGoods{
    self.goods = [[GoodsModel alloc]init];
    _goods.ID = @"001";
    _goods.imageUrl = @"http://www.baidu/image.com";
    _goods.name = @"myImage";
    //link 点击图片的跳转链接
    _goods.link = @"http://www.baidu.com";
    _goods.content = @"abcd";
}
- (void)addGoods:(GoodsModel*)goods{
        [[LHManage sharedLH]addGoods:goods];
}
- (void)searchAllModel{
    NSArray * arrayModel = [[LHManage sharedLH]searchAllModelWithModle:[GoodsModel class]];
    if (arrayModel.count == 0) {
        NSLog(@"数据为空");
    }else{
        for (GoodsModel * model in arrayModel) {
            NSLog(@"\n\n");
            NSLog(@"----------------------------------------------");
            NSLog(@"id = %@",model.ID);
            NSLog(@"imageUrl = %@",model.imageUrl);
            NSLog(@"name = %@",model.name);
            NSLog(@"link = %@",model.link);
            NSLog(@"content = %@",model.content);
            NSLog(@"----------------------------------------------");
            NSLog(@"\n\n");
        }
    }
}
- (void)searchAValueP:(NSString*)PRIMARYKEYValue withKey:(NSString*)key{
    //
    NSLog(@"--------------value---------------- = %@",[[LHManage sharedLH] searchAProWithPRIMARYKEYValue:PRIMARYKEYValue withKey:key withModelClass:[GoodsModel class]]);
}
- (void)updateAValueDataWithPRIMARYKEYValue:(NSString*)PRIMARYKEYValue withKey:(NSString*)key withValue:(NSString*)value{
    [[LHManage sharedLH]updateGoodsWithModelClass:[GoodsModel class] withPRIMARYKEYValue:self.goods.ID withKey:@"link" withValue:@"http://www.google.com"];
    //修改完查询
    NSLog(@"----------------new----------------");
    [self searchAValueP:self.goods.ID withKey:@"link"];
}

@end
