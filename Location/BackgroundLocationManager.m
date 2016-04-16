//
//  BackgroundLocationManager.m
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import "BackgroundLocationManager.h"
#import <UIKit/UIKit.h>

@interface BackgroundLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, assign) NSInteger num; //定位计数，用以判断每次程序启动定位了几次

@end

@implementation BackgroundLocationManager

static BackgroundLocationManager *manager;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BackgroundLocationManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    //定位精度
    [self setDistanceFilter:kCLLocationAccuracyBest];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        //请求定位
        [self requestAlwaysAuthorization];
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        //允许后台定位
        [self setAllowsBackgroundLocationUpdates:YES];
    }
    self.num = 0;
    self.delegate =self;
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *loc = locations[0];
    NSLog(@"后台or前台定位 -- %@",locations[0]);
    
    //将位置数据不断写入沙盒
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [NSString stringWithFormat:@"%@/BackgroundLocationManager.plist",path];
    NSMutableArray *tempAr =[[NSArray arrayWithContentsOfFile:path] mutableCopy];
    if (!tempAr) {
        tempAr = [[NSMutableArray alloc]init];
    }
    NSString *detailTextLabel = [NSString stringWithFormat:@"经度%f  纬度%f 速度 %.1f",loc.coordinate.longitude,loc.coordinate.latitude,loc.speed];
    NSString *textLabel;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        textLabel = [NSString stringWithFormat:@"程序手动启动，-后台-第%ld次定位",(long)_num] ;
    }else{
         textLabel = [NSString stringWithFormat:@"程序手动启动，-前台-第%ld次定位",(long)_num] ;
    }
    
    NSDictionary *dic = @{@"textLabel":textLabel,@"detailTextLabel":detailTextLabel,@"num":@(_num),@"isBackground":@(([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)),@"date":[NSString stringWithFormat:@"%@",[NSDate new]]};
    [tempAr addObject:dic];
    //写入沙盒
    [tempAr writeToFile:path atomically:YES];
    //发送通知，刷新界面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundLocationManagerDidUpdateLocations" object:nil];
    
    self.num++;
}

@end
