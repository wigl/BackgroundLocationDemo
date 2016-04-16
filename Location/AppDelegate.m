//
//  AppDelegate.m
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import "AppDelegate.h"
#import "SignificantLocationVC.h"
#import "SignificantLocationManager.h"
#import "BakcgoundLocationVC.h"
#import "BackgroundLocationManager.h"

@interface AppDelegate ()<CLLocationManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarHidden = YES;
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UITabBarController *tab = [[UITabBarController alloc]init];
    tab.tabBar.translucent = NO;
    SignificantLocationVC *slvc = [[SignificantLocationVC alloc]init];
    slvc.title = @"重大位置改变定位";
    BakcgoundLocationVC *blvc = [[BakcgoundLocationVC alloc]init];
    blvc.title = @"后台持续定位";
    tab.viewControllers = @[slvc,blvc];
    _window.rootViewController = tab;
    [_window makeKeyAndVisible];
    
    //创建定位管理者单例
    SignificantLocationManager *manager = [SignificantLocationManager shareManager];
    //当launchOptions中有UIApplicationLaunchOptionsLocationKey表明是系统因为位置发生重大变化，自动启动了程序
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        manager.isRunFromeSystem = YES;
    }
    //开始重大位置改变定位
    [manager startMonitoringSignificantLocationChanges];
    return YES;
}

@end
