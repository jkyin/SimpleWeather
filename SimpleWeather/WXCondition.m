//
//  WXCondition.m
//  SimpleWeather
//
//  Created by Yin on 14-2-28.
//  Copyright (c) 2014年 Yin. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition

+ (NSDictionary *)imageMap
{
    // 创建一个静态的NSDictionary，因为WXCondition的每个实例都将使用相同的数据映射
    static NSDictionary *_imageMap = nil;
    
    if (!_imageMap) {
        // 天气状况与图像文件的关系（例如“01d”代表“weather-clear.png”）
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // 在这个方法里，dictionary 的 key 是 WXCondition 的属性名称，而 dictionary 的 value 是 JSON 的路径
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

+ (NSValueTransformer *)dateJSONTransformer
{
    // 使用 blocks 做属性的转换的工作，并返回一个 MTLValueTransformer 返回值
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
                return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
            } reverseBlock:^(NSDate *date) {
                return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
            }];
}

+ (NSValueTransformer *)sunriseJSONTransformer
{
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer
{
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

#define MPS_TO_MPH 2.23694f

// OpenWeatherAPI 使用每秒/米的风速。由于 App 使用英制系统，需要将其转换为每小时/英里
+ (NSValueTransformer *)windSpeedJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue * MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue / MPS_TO_MPH);
    }];
}

- (NSString *)imageName
{
    // 获取图像文件名
    return [WXCondition imageMap][self.icon];
}

@end







