//
//  LMTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMTool.h"
#import "sys/utsname.h"
#import "LMNetworkTool.h"
#import "LMDatabaseTool.h"

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

//初始化第一次启动用户数据
+(void)initFirstLaunchData {
    //创建 表
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    [tool createBookShelfTable];
    [tool createSourceTable];
    [tool createLastChapterTable];
    
    
    //阅读器界面 配置 初始化
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:@"LMReaderConfig.plist"];
    NSMutableDictionary* configDic = [NSMutableDictionary dictionary];
    [configDic setObject:@1 forKey:@"readerModelDay"];
    [configDic setObject:@16 forKey:@"readerFont"];
    [configDic setObject:@"目录" forKey:@"readerCatalog"];
    [configDic setObject:@"下载" forKey:@"readerDownload"];
    [configDic setObject:@"分享" forKey:@"readerShare"];
    [configDic writeToFile:plistPath atomically:YES];
    
    [LMNetworkTool sharedNetworkTool];
}

//修改阅读器 配置
+(void)changeReaderConfigWithReaderModelDay:(BOOL )day fontSize:(CGFloat )fontSize {
    NSNumber* modelNum = @0;
    if (day) {
        modelNum = @1;
    }
    NSNumber* fontNum = @16;
    if (fontSize) {
        fontNum = [NSNumber numberWithFloat:fontSize];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:@"LMReaderConfig.plist"];
    NSMutableDictionary* configDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    [configDic setObject:modelNum forKey:@"readerModelDay"];
    [configDic setObject:fontNum forKey:@"readerFont"];
    
    [configDic writeToFile:plistPath atomically:YES];
}

//iPhone X ?
+(BOOL )isIPhoneX {
    CGRect rect = CGRectMake(0, 0, 375, 812);
    CGRect deviceRect = [UIScreen mainScreen].bounds;
    return CGRectEqualToRect(deviceRect, rect);
}

//uuid
+(NSString* )uuid {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

//系统版本
+(NSString* )systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

//设备型号
+(NSString* )deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
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

+(DeviceUdId* )protobufDeviceUuId {
    DeviceUdIdBuilder* builder = [DeviceUdId builder];
    [builder setUuid:[LMTool uuid]];
    return [builder build];
}

+(DeviceSize* )protobufDeviceSize {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    DeviceSizeBuilder* builder = [DeviceSize builder];
    [builder setWidth: (UInt32)screenRect.size.width];
    [builder setHeight:(UInt32)screenRect.size.height];
    return [builder build];
}

+(Device* )protobufDevice {
    DeviceDeviceType type = DeviceDeviceTypeDevicePhone;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        type = DeviceDeviceTypeDevicePhone;
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        type = DeviceDeviceTypeDeviceTablet;
    }else {
        type = DeviceDeviceTypeDeviceUnknown;
    }
    DeviceBuilder* devideBuild = [Device builder];
    [devideBuild setDeviceType:type];
    [devideBuild setOsType:DeviceOsTypeIos];
    [devideBuild setOsVersion:[LMTool systemVersion]];
    [devideBuild setVendor:[@"Apple" dataUsingEncoding:NSUTF8StringEncoding]];
    [devideBuild setModel:[[LMTool deviceModel] dataUsingEncoding:NSUTF8StringEncoding]];
    [devideBuild setUdid:[LMTool protobufDeviceUuId]];
    [devideBuild setScreenSize:[LMTool protobufDeviceSize]];
    
    return [devideBuild build];
}


//将时间戳转换成时间
+(NSString* )convertTimeStampToTime:(UInt64 )timeStamp {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //以 1970/01/01 GMT为基准，然后过了secs秒的时间
    NSDate *stampDate2 = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString* dateStr = [stampFormatter stringFromDate:stampDate2];
    return dateStr;
}


@end
