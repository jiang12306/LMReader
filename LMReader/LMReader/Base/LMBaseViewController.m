//
//  LMBaseViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMBaseViewController () <UIGestureRecognizerDelegate>

@end

@implementation LMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    //配置右滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    //标题颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //表头 半透明
    self.navigationController.navigationBar.translucent = YES;
    
}

//显示 网络加载 视图
-(void)showNetworkLoadingView {
    if (!self.loadingView) {
        self.loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingView.frame = CGRectMake(0, 0, 30, 30);
        self.loadingView.hidesWhenStopped = YES;
        self.loadingView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        [self.view insertSubview:self.loadingView atIndex:999];
        
        self.loadingView.hidden = YES;
    }
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    [self.view bringSubviewToFront:self.loadingView];
}

//隐藏 网络加载 视图
-(void)hideNetworkLoadingView {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
}

-(void)dealloc {
//    [self.loadingView removeFromSuperview];
//    self.loadingView = nil;
    
    NSLog(@"---------dealloc---------");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
