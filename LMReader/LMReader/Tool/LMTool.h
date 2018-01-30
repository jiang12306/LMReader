//
//  LMTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMTool : NSObject

//是否第一次launch
+(BOOL )isFirstLaunch;

//删除启动次数
+(void)clearLaunchCount;

//启动次数+1
+(void)incrementLaunchCount;

@end
