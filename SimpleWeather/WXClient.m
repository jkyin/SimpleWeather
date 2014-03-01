//
//  WXClient.m
//  SimpleWeather
//
//  Created by Yin on 14-2-28.
//  Copyright (c) 2014年 Yin. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WXClient

- (id)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching: %@", url.absoluteString);
    
    // 返回信号。请记住，这将不会执行，直到这个信号被订阅。 - fetchJSONFromURL：创建一个对象给其他方法和对象使用；这种行为有时也被称为工厂模式
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 创建一个 NSURLSessionDataTask（在iOS7中加入）从 URL 取数据
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    // 当JSON数据存在并且没有错误，发送给订阅者序列化后的JSON数组或字典
                    [subscriber sendNext:json];
                }
                else {
                    // 在任一情况下如果有一个错误，通知订阅者
                    [subscriber sendNext:jsonError];
                }
            }
            else {
                // 在任一情况下如果有一个错误，通知订阅者
                [subscriber sendNext:error];
            }
            
            // 无论该请求成功还是失败，通知订阅者请求已经完成
            [subscriber sendCompleted];
        }];
        
        // 一旦订阅了信号，启动网络请求
        [dataTask resume];
        
        // 创建并返回 RACDisposable 对象，它处理当信号摧毁时的清理工作
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        // 增加了一个 “side effect”，以记录发生的任何错误。side effect 不订阅信号，相反，他们返回被连接到方法链的信号
        NSLog(@"%@", error);
    }];
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    // 使用 CLLocationCoordinate2D 对象的经纬度数据来格式化 URL
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial", coordinate.latitude, coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 使用 MTLJSONAdapter 来转换 JSON 到 WXCondition 对象 – 使用 MTLJSONSerializing 协议创建的 WXCondition
        return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 再次使用 -fetchJSONFromUR: 方法，映射 JSON
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 使用 JSON 的 "list" key 创建 RACSequence。RACSequences 让你对列表进行 ReactiveCocoa 操作
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 映射新的对象列表。调用 -map：方法，针对列表中的每个对象，返回新对象的列表
        return [[list map:^(NSDictionary *item) {
            // 再次使用 MTLJSONAdapter 来转换 JSON 到 WXCondition 对象
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];

            // 使用 RACSequence 的 -map: 方法，返回另一个 RACSequence，所以用这个简便的方法来获得一个 NSArray 数据
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end









