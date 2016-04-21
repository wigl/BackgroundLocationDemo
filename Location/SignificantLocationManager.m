//
//  SignificantLocationManager.m
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

/**
 * 1.重大位置定位，该定位开启后，无论应用是否启动，是否被用户手动退出，当位置发生重大变化时，系统都会后台唤醒程序
 * 2.重大位置变化定位是基于基站（即：移动、联通、电信等基站）进行定位的，如果手机没有SIM卡，那该功能不能使用
 */

#import "SignificantLocationManager.h"
#import <UIKit/UIKit.h>

@interface SignificantLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, assign) NSInteger num; //定位计数，用以判断每次程序启动定位了几次

@end

@implementation SignificantLocationManager

/**
 * 1.单例，重大位置改变定位需要使用单例而且必须在didFinishLaunchingWithOptions进行初始化
 * 2.因为假如应用被系统或者用户强制退出，当有重大位置改变时候，系统会重新启动程序，从而调用didFinishLaunchingWithOptions方法，但是这时候系统后台启动程序，所以只有将SignificantLocationManager的初始化放在didFinishLaunchingWithOptions才能保证每次系统自动启动程序可以进行初始化
 * 3.单例的目的是保证对象不被销毁，也可以保证不会重复创建
 */
static SignificantLocationManager *manager;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SignificantLocationManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [self requestAlwaysAuthorization];
    }
    self.num = 0;
    self.delegate =self;
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *loc = locations[0];
    NSLog(@"重大位置改变定位 -- %@",locations[0]);

    //定位数据
    NSString *detailTextLabel = [NSString stringWithFormat:@"经度%f  纬度%f 速度 %.1f",loc.coordinate.longitude,loc.coordinate.latitude,loc.speed];
    NSString *textLabel;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        if (_isRunFromeSystem) {
            textLabel = [NSString stringWithFormat:@"系统自动启动程序，-后台-第%ld次定位",(long)_num] ;
        }else{
            textLabel = [NSString stringWithFormat:@"程序手动启动，-后台-第%ld次定位",(long)_num] ;
        }
    }else{
        if (_isRunFromeSystem) {
            textLabel = [NSString stringWithFormat:@"系统自动启动程序，-前台-第%ld次定位",(long)_num] ;
        }else{
            textLabel = [NSString stringWithFormat:@"程序手动启动，-前台-第%ld次定位",(long)_num] ;
        }
    }
    
    NSDictionary *dic = @{@"textLabel":textLabel,@"detailTextLabel":detailTextLabel,@"num":@(_num),@"isRunFromeSystem":@(_isRunFromeSystem),@"isBackground":@(([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)),@"date":[NSString stringWithFormat:@"%@",[NSDate new]]};
    
    //将位置数据不断写入沙盒
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [NSString stringWithFormat:@"%@/SignificantLocationManager.plist",path];
    NSMutableArray *tempAr =[[NSArray arrayWithContentsOfFile:path] mutableCopy];
    if (!tempAr) {
        tempAr = [[NSMutableArray alloc]init];
    }
    [tempAr addObject:dic];
    //写入沙盒
    [tempAr writeToFile:path atomically:YES];
    //发送通知，刷新界面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignificantLocationDidUpdateLocations" object:nil];
    self.num++;

    //如果你需要上传位置信息，且程序处于后台，需要调用beginBackgroundTaskWithExpirationHandler来执行网络请求操作
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UIApplication *application = [UIApplication sharedApplication];
        //申请开台时间
        __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //上传地理位置信息..
//            NSURLSession *session = ...
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    }
}

@end