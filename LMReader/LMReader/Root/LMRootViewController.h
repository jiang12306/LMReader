//
//  LMRootViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMRootViewController : LMBaseViewController

+(instancetype )sharedRootViewController;

/** 更改启动根视图
 *  @param isFirstLaunch 是否第一次启动  YES：是   NO：否
 */
-(void)exchangeLaunchState:(BOOL)isFirstLaunch;

@end
