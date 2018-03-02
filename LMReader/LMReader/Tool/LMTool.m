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
#import "AppDelegate.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation LMTool

static NSString* launchCount = @"launchCount";
static NSString* currentUserId = @"currentUserId";

//是否第一次launch
+(BOOL)isFirstLaunch {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:keyStr];
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
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:keyStr];
    [defaults synchronize];
}

//启动次数+1
+(void)incrementLaunchCount {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSInteger countInteger = 0;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:keyStr];
    if (count != nil && [count isKindOfClass:[NSNull class]]) {
        countInteger = [count integerValue];
    }
    countInteger ++;
    
    [defaults setObject:[NSNumber numberWithInteger:countInteger] forKey:keyStr];
    [defaults synchronize];
}

//初始化第一次启动用户数据
+(void)initFirstLaunchData {
    //创建用户文件夹
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* userFilePath = [LMTool getUserFilePath];
    
    //阅读器界面 配置 初始化
    NSString* plistPath = [userFilePath stringByAppendingPathComponent:@"LMReaderConfig.plist"];
    if (![fileManager fileExistsAtPath:plistPath]) {
        NSMutableDictionary* configDic = [NSMutableDictionary dictionary];
        [configDic setObject:@1 forKey:@"readerModelDay"];
        [configDic setObject:@18 forKey:@"readerFont"];
        [configDic setObject:@"目录" forKey:@"readerCatalog"];
        [configDic setObject:@"下载" forKey:@"readerDownload"];
        [configDic setObject:@"分享" forKey:@"readerShare"];
        [configDic writeToFile:plistPath atomically:YES];
    }
    
    
    
    //创建 表
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    [tool createAllFirstLaunchTable];
    
    
    
    [LMNetworkTool sharedNetworkTool];
}

//获取用户文件夹目录
+(NSString* )getUserFilePath {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* userFilePath = [documentPath stringByAppendingPathComponent:appDelegate.userId];
    BOOL isDir;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFilePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:userFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return userFilePath;
}

//获取 阅读界面 配置
+(void)getReaderConfig:(void (^) (CGFloat fontSize, NSInteger modelInteger))block {
    NSString* userFilePath = [LMTool getUserFilePath];
    NSString* plistPath = [userFilePath stringByAppendingPathComponent:@"LMReaderConfig.plist"];
    NSDictionary* configDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    CGFloat fontSize = [[configDic objectForKey:@"readerFont"] floatValue];
    NSInteger modelInteger = [[configDic objectForKey:@"readerModelDay"] integerValue];
    block(fontSize, modelInteger);
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
    NSString* userFilePath = [LMTool getUserFilePath];
    NSString* plistPath = [userFilePath stringByAppendingPathComponent:@"LMReaderConfig.plist"];
    NSMutableDictionary* configDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    [configDic setObject:modelNum forKey:@"readerModelDay"];
    [configDic setObject:fontNum forKey:@"readerFont"];
    
    [configDic writeToFile:plistPath atomically:YES];
}

//
+(BOOL )deviceIsBinding {
    NSString* uuidStr = [LMTool uuid];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [defaults objectForKey:uuidStr];
    if (userId != nil && ![userId isKindOfClass:[NSNull class]] && userId.length > 0) {
        return YES;
    }
    return NO;
}

//获取当前userId
+(NSString* )getAppUserId {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([LMTool deviceIsBinding]) {
        NSString* userId = [defaults objectForKey:currentUserId];
        return userId;
    }else {
        NSString* uuidStr = [LMTool uuid];
        uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        return uuidStr;
    }
}

//将设备号与用户绑定
+(void)bindDeviceToUser:(LoginedRegUser* )loginUser {
    NSString* userId = loginUser.user.uid;
    NSString* uuidStr = [LMTool uuid];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([LMTool deviceIsBinding]) {//设备已经被绑定过
        NSString* bindUserId = [LMTool getAppUserId];
        if ([bindUserId isEqualToString:uuidStr]) {//设备绑定的是当前账号
            return;
        }
        
        //根据用户id来创建用户目录文件夹、设置APPDelegate.userId、创建数据表
        
        [defaults setObject:userId forKey:currentUserId];
        [defaults synchronize];
        
        //初始化用户数据
        [LMTool initFirstLaunchData];
        
        //To Do...
        
    }else {
        [defaults setObject:userId forKey:uuidStr];
        [defaults setObject:uuidStr forKey:currentUserId];
        [defaults synchronize];
    }
    
}

//保存用户信息
+(void)saveLoginedRegUser:(LoginedRegUser* )loginedUser {
    NSString* token = loginedUser.token;
    RegUser* regUser = loginedUser.user;
    NSString* uidStr = regUser.uid;
    NSString* phoneNumStr = regUser.phoneNum;
    NSString* emailStr = regUser.email;
    GenderType genderType = regUser.gender;
    NSNumber* genderNum = @0;
    if (genderType == GenderTypeGenderMale) {
        genderNum = @1;
    }else if (genderType == GenderTypeGenderFemale) {
        genderNum = @2;
    }else if (genderType == GenderTypeGenderOther) {
        genderNum = @3;
    }
    NSString* birthdayStr = regUser.birthday;
    NSString* localAreaStr = regUser.localArea;
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:token forKey:@"token"];
    [dic setObject:uidStr forKey:@"uid"];
    [dic setObject:phoneNumStr forKey:@"phoneNum"];
    [dic setObject:emailStr forKey:@"email"];
    [dic setObject:genderNum forKey:@"gender"];
    [dic setObject:birthdayStr forKey:@"birthday"];
    [dic setObject:localAreaStr forKey:@"localArea"];
    
    [dic writeToFile:plistPath atomically:YES];
}

//获取用户信息
+(LoginedRegUser* )getLoginedRegUser {
    LoginedRegUserBuilder* builder = [LoginedRegUser builder];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:plistPath]) {
        return nil;
    }
    
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString* tokenStr = [dic objectForKey:@"token"];
    NSString* uidStr = [dic objectForKey:@"uid"];
    NSString* phoneNumStr = [dic objectForKey:@"phoneNum"];
    NSString* emailStr = [dic objectForKey:@"email"];
    NSNumber* genderNum = [dic objectForKey:@"gender"];
    NSInteger genderInt = [genderNum integerValue];
    GenderType type = GenderTypeGenderUnknown;
    if (genderInt == 1) {
        type = GenderTypeGenderMale;
    }else if (genderInt == 2) {
        type = GenderTypeGenderFemale;
    }else if (genderInt == 3) {
        type = GenderTypeGenderOther;
    }
    NSString* birthdayStr = [dic objectForKey:@"birthday"];
    NSString* localAreaStr = [dic objectForKey:@"localArea"];
    
    RegUserBuilder* userBuilder = [RegUser builder];
    [userBuilder setUid:uidStr];
    [userBuilder setPhoneNum:phoneNumStr];
    [userBuilder setEmail:emailStr];
    [userBuilder setGender:type];
    [userBuilder setBirthday:birthdayStr];
    [userBuilder setLocalArea:localAreaStr];
    RegUser* regUser = [userBuilder build];
    
    [builder setToken:tokenStr];
    [builder setUser:regUser];
    
    LoginedRegUser* user = [builder build];
    return user;
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

//MD5加密, 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str {
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}


@end
