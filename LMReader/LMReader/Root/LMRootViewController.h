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
 *  @param index 当前item的角标 0：书架  1：精选   2：书城  3：我的
 */
-(void)setCurrentViewControllerIndex:(NSInteger )index;

/** 回到TabBarController当前显示vc
 *  @param index 当前item的角标 0：书架  1：精选   2：书城  3：我的
 */
-(void)backToTabBarControllerWithViewControllerIndex:(NSInteger )index;

/** 跳转至vc
 *  @param classString 类型字符串  为空时表示回到首页书架页
 *  @param paramString 传过来的参数
 */
-(void)openViewControllerCalss:(NSString* )classString paramString:(NSString* )paramString;

/** 设置角标红点
 *  @param showRedDot NO：不显示；YEs：显示
 *  @param index 当前item的角标 0：书架  1：精选   2：书城  3：我的
 */
-(void)setupShowRedDot:(BOOL )showRedDot index:(NSInteger )index;

/** 获取是否有角标红点
 *  @param index 当前item的角标 0：书架  1：精选   2：书城  3：我的
 */
-(BOOL )getShowRedDotWithIndex:(NSInteger )index;

@end
