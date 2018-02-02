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

//iPhone X ?
+(BOOL )isIPhoneX {
    CGRect rect = CGRectMake(0, 0, 375, 812);
    CGRect deviceRect = [UIScreen mainScreen].bounds;
    return CGRectEqualToRect(deviceRect, rect);
}

//机型 4、4s,5、5c、5s,6、7、8,6p、7p、8p,x
+(NSString *)deviceType {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight == 480) {
        return @"4";
    }else if (screenHeight == 568) {
        return @"5";
    }else if (screenHeight == 667) {
        return @"6";
    }else if (screenHeight == 736) {
        return @"6p";
    }else if (screenHeight == 812) {
        return @"x";
    }
    return @"unknow";
}


@end
