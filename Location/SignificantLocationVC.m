//
//  SignificantLocationVC.m
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import "SignificantLocationVC.h"

@interface SignificantLocationVC ()
@property (nonatomic, strong) NSArray *locAry;

@end

@implementation SignificantLocationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"SignificantLocationDidUpdateLocations" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

-(void)refresh{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [NSString stringWithFormat:@"%@/SignificantLocationManager.plist",path];
    _locAry =[NSArray arrayWithContentsOfFile:path];
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _locAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifi = @"SignificantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifi];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifi];
    }
    NSDictionary *dic = _locAry[indexPath.row];
    cell.textLabel.text = dic[@"textLabel"];;
    cell.detailTextLabel.text = dic[@"detailTextLabel"];
    NSNumber *isLocationKey = dic[@"isRunFromeSystem"];
    NSNumber *isBackground = dic[@"isBackground"];
    
    //绿色表示系统自动启动程序，在后台定位;蓝色表示系统自动启动程序，在前台定位
    //系统自动启动
    if (!([isLocationKey intValue] == 0)) {
        if (!([isBackground intValue] == 0)) {
            //后台定位的数据
            cell.textLabel.textColor = [UIColor greenColor];
            cell.detailTextLabel.textColor = [UIColor greenColor];
        }else{
            //前台定位的数据，表明系统自动启动了程序，而我们刚好也手动点击了程序，从而使程序此时在前台
            cell.textLabel.textColor = [UIColor blueColor];
            cell.detailTextLabel.textColor = [UIColor blueColor];
        }
    }else if ([isLocationKey intValue] == 0){
        if (!([isBackground intValue] == 0)) {
            //手动启动程序，后台刷新数据为红色
            cell.textLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.textColor = [UIColor redColor];
        }else{
            //前台刷新的数据
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}

@end
