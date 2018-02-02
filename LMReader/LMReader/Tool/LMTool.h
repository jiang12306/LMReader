//
//  LMTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LMTool : NSObject

//是否第一次launch
+(BOOL )isFirstLaunch;

//删除启动次数
+(void)clearLaunchCount;

//启动次数+1
+(void)incrementLaunchCount;

//iPhone X ?
+(BOOL )isIPhoneX;

//设备机型 4、4s,5、5c、5s,6、7、8,6p、7p、8p,x
+(NSString* )deviceType;

@end
