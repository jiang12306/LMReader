//
//  LMBaseTabBarController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMBaseTabBarController : UITabBarController

/** 显示tabBar红点
 *  @prama index 从0开始
 */
-(void)showTabBarItemRedDotWithIndex:(NSInteger )index;

/** 隐藏tabBar红点
 *  @prama index 从0开始
 */
-(void)hideTabBarItemRedDotWithIndex:(NSInteger )index;

/** 获取是否有tabBar红点
 *  @prama index 从0开始
 */
-(BOOL )getTabBarItemRedDotWithIndex:(NSInteger )index;

@end
