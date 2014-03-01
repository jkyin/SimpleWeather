//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by Yin on 14-2-28.
//  Copyright (c) 2014年 Yin. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // 获取 WXCondition 的映射，并创建它的可变副本
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    // 改变 max 和 min 键映射
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    return paths;
}

@end
