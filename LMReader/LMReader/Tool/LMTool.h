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

//修改阅读器 配置
+(void)changeReaderConfigWithReaderModelDay:(BOOL )day fontSize:(CGFloat )fontSize;

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

@end
