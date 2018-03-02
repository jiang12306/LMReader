//
//  LMTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Ftbook.pb.h"

@interface LMTool : NSObject

//是否第一次launch
+(BOOL )isFirstLaunch;

//删除启动次数
+(void)clearLaunchCount;

//启动次数+1
+(void)incrementLaunchCount;

//初始化第一次启动用户数据
+(void)initFirstLaunchData;

//获取用户文件夹目录
+(NSString* )getUserFilePath;

//获取 阅读界面 配置
+(void)getReaderConfig:(void (^) (CGFloat fontSize, NSInteger modelInteger))block;

//修改阅读器 配置
+(void)changeReaderConfigWithReaderModelDay:(BOOL )day fontSize:(CGFloat )fontSize;

//获取当前userId
+(NSString* )getAppUserId;

//将设备号与用户绑定
+(void)bindDeviceToUser:(LoginedRegUser* )loginUser;

//保存用户信息
+(void)saveLoginedRegUser:(LoginedRegUser* )loginedUser;

//获取用户信息
+(LoginedRegUser* )getLoginedRegUser;

//iPhone X ?
+(BOOL )isIPhoneX;

//uuid
+(NSString* )uuid;

//设备机型 4、4s,5、5c、5s,6、7、8,6p、7p、8p,x
+(NSString* )deviceType;

//protobuf device 设备信息
+(Device* )protobufDevice;

//将时间戳转换成时间
+(NSString* )convertTimeStampToTime:(UInt64 )timeStamp;


//MD5加密, 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str;

@end
