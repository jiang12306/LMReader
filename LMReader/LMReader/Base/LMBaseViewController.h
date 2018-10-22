//
//  LMBaseViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMNetworkTool.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface LMBaseViewController : UIViewController

//显示 网络加载
-(void)showNetworkLoadingView;
//隐藏 网络加载
-(void)hideNetworkLoadingView;

//MBProgressHUD
-(void)showMBProgressHUDWithText:(NSString* )hudText;

//显示 刷新按钮
-(void)showReloadButton;
//隐藏 刷新按钮
-(void)hideReloadButton;
//点击 刷新按钮
-(void)clickedSelfReloadButton:(UIButton* )sender;

//显示 无数据
-(void)showEmptyLabelWithText:(NSString* )emptyText;
//显示 无数据 指定frame
-(void)showEmptyLabelWithCenterPoint:(CGPoint )centerPoint text:(NSString* )emptyText;
//隐藏 无数据
-(void)hideEmptyLabel;

@end
