//
//  UITabBar+LMBadge.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (LMBadge)

//显示红点 从0开始
-(void)showBadgeOnItemIndex:(NSInteger )index;

//隐藏红点 从0开始
-(void)hideBadgeOnItemIndex:(NSInteger )index;

//获取是否有红点 从0开始
-(BOOL )getBadgeOnItemIndex:(NSInteger )index;

@end

NS_ASSUME_NONNULL_END
