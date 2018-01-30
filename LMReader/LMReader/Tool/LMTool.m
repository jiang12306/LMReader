//
//  LMTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMTool.h"

@implementation LMTool

static NSString* launchCount = @"launchCount";

//是否第一次launch
+(BOOL)isFirstLaunch {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:launchCount];
    if (count == nil) {
        return YES;
    }
    if ([count isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (count.integerValue == 0) {
        return YES;
    }
    return NO;
}

//删除启动次数
+(void)clearLaunchCount {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:launchCount];
    [defaults synchronize];
}

//启动次数+1
+(void)incrementLaunchCount {
    NSInteger countInteger = 0;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:launchCount];
    if (count != nil && [count isKindOfClass:[NSNull class]]) {
        countInteger = [count integerValue];
    }
    countInteger ++;
    
    [defaults setObject:[NSNumber numberWithInteger:countInteger] forKey:launchCount];
    [defaults synchronize];
}

@end
