//
//  BackgroundLocationManager.h
//  Location
//
//  Created by cardvalue on 16/4/14.
//  Copyright © 2016年 jinpeng. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface BackgroundLocationManager : CLLocationManager
+ (instancetype)shareManager;

@end
