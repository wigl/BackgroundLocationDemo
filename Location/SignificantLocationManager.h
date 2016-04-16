//
//  SignificantLocationManager.h
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface SignificantLocationManager : CLLocationManager
@property (nonatomic, assign) BOOL isRunFromeSystem; //是否是系统因为位置发生重大变化，自动启动了程序
+ (instancetype)shareManager;

@end
