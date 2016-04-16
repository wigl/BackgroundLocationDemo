//
//  BakcgoundLocationVC.m
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import "BakcgoundLocationVC.h"
#import "BackgroundLocationManager.h"

@interface BakcgoundLocationVC ()
@property (nonatomic, strong) NSArray *locAry;

@end

@implementation BakcgoundLocationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    BackgroundLocationManager *mange = [BackgroundLocationManager shareManager];
    [mange startUpdatingLocation];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"BackgroundLocationManagerDidUpdateLocations" object:nil];
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
    path = [NSString stringWithFormat:@"%@/BackgroundLocationManager.plist",path];
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
    
    if ([isLocationKey intValue] == 0){
        if (!([isBackground intValue] == 0)) {
            //手动启动程序，后台刷新数据为红色
            cell.textLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.textColor = [UIColor redColor];
        }else{
            //前台刷新的数据，为黑色
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}

@end