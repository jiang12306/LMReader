//
//  LMBaseViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ftbook.pb.h"
#import "LMNetworkTool.h"

@interface LMBaseViewController : UIViewController

@property (nonatomic, strong) UIActivityIndicatorView* loadingView;//

-(void)showNetworkLoadingView;//显示 网络加载 视图
-(void)hideNetworkLoadingView;//隐藏 网络加载 视图

-(void)showMBProgressHUDWithText:(NSString* )hudText;

@end
