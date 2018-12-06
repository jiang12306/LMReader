//
//  UITabBar+LMBadge.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "UITabBar+LMBadge.h"

@implementation UITabBar (LMBadge)


#define TabbarItemNums 4.0 //tabbar的数量

//显示红点
-(void)showBadgeOnItemIndex:(NSInteger )index {
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    CGRect tabFrame = self.frame;
    //小红点的位置
    float percentX = (index + 0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.13 * tabFrame.size.height);
    CGRect badgeRect = CGRectMake(x, y, 8, 8);
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = badgeRect.size.width / 2;
    badgeView.backgroundColor = THEMEORANGECOLOR;
    badgeView.frame = badgeRect;
    
    [self addSubview:badgeView];
}

//隐藏红点
-(void)hideBadgeOnItemIndex:(NSInteger )index {
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(NSInteger )index{
    //按照tag值进行移除
    for (UIView* subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

//
-(BOOL )getBadgeOnItemIndex:(NSInteger)index {
    //按照tag值
    BOOL result = NO;
    for (UIView* subView in self.subviews) {
        if (subView.tag == 888+index) {
            result = YES;
            break;
        }
    }
    return result;
}

@end
