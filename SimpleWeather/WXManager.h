//
//  WXManager.h
//  SimpleWeather
//
//  Created by Yin on 14-2-28.
//  Copyright (c) 2014年 Yin. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>
// 始终使用 WXCondition 作为预报的类。 WXDailyForecast 的存在是为了帮助 Mantle 转换 JSON 到 Objective-C
#import "WXCondition.h"

@interface WXManager : NSObject <CLLocationManagerDelegate>

// 使用 instancetype 而不是 WXManager，子类将返回适当的类型
+ (instancetype)sharedManager;

// 这些属性将存储您的数据。由于 WXManager 是一个单例，这些属性可以任意访问。设置公共属性为只读，因为只有管理者能更改这些值
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 这个方法启动或刷新整个位置和天气的查找过程
- (void)findCurrentLocation;

@end
