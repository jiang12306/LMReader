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

/** 更改当前显示vc
 *  @param index 当前item的角标 0：书架  1：精选  2：我的
 */
-(void)setCurrentViewControllerIndex:(NSInteger )index;

@end
