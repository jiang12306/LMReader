//
//  LMBaseViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"
#import "MBProgressHUD.h"
#import <UMAnalytics/MobClick.h>

@interface LMBaseViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>
//网络加载视图
@property (nonatomic, strong) UIView* loadingView;
@property (nonatomic, strong) UIImageView* loadingIV;
@property (nonatomic, strong) UILabel* loadingLab;

//刷新按钮
@property (nonatomic, strong) UIButton* selfReloadBtn;

//无数据 提示label
@property (nonatomic, strong) UILabel* emptyLabel;

@end

@implementation LMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    //配置右滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.delegate = self;
    
    //标题颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    if (@available(ios 11.0, *)) {
        
    }else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    //表头 半透明
    self.navigationController.navigationBar.translucent = NO;//YES;//如果需要半透明，则LMBaseRefreshTableView则需要添加contentOffset监听，否则“下拉刷新”会显示在表头底下；WebView有进度条的话注意进度条位置
    
    if (@available(iOS 9.0, *)) {
        
    }else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //友盟统计
    NSString* pageName = NSStringFromClass([self class]);
    [MobClick beginLogPageView:pageName];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //友盟统计
    NSString* pageName = NSStringFromClass([self class]);
    [MobClick endLogPageView:pageName];
}

#pragma mark -UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count > 0) {
        if (viewController == navigationController.viewControllers[0]) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else {
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

//显示 网络加载
-(void)showNetworkLoadingView {
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, (self.view.frame.size.height - 70 - 70)/2, 70, 70)];//去掉表头70
        self.loadingView.backgroundColor = [UIColor colorWithRed:40.f/255 green:40.f/255 blue:40.f/255 alpha:0.6];
        self.loadingView.layer.cornerRadius = 5;
        self.loadingView.layer.masksToBounds = YES;
        
        self.loadingIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 30)];
        NSMutableArray* imgArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 7; i ++) {
            NSString* imgStr = [NSString stringWithFormat:@"loading%ld", (long)i];
            UIImage* img = [UIImage imageNamed:imgStr];
            [imgArr addObject:img];
        }
        self.loadingIV.animationImages = imgArr;
        self.loadingIV.animationDuration = 1;
        [self.loadingView addSubview:self.loadingIV];
        
        self.loadingLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.loadingView.frame.size.height - 25, self.loadingView.frame.size.height, 20)];
        self.loadingLab.textColor = [UIColor whiteColor];
        self.loadingLab.textAlignment = NSTextAlignmentCenter;
        self.loadingLab.font = [UIFont systemFontOfSize:14];
        self.loadingLab.text = @"加载中···";
        [self.loadingView addSubview:self.loadingLab];
        
        [self.view insertSubview:self.loadingView atIndex:999];
        self.loadingView.hidden = YES;
    }
    self.loadingView.hidden = NO;
    [self.loadingIV startAnimating];
    [self.view bringSubviewToFront:self.loadingView];
}

//隐藏 网络加载
-(void)hideNetworkLoadingView {
    [self.loadingIV stopAnimating];
    self.loadingView.hidden = YES;
}

//MBProgressHUD
-(void)showMBProgressHUDWithText:(NSString *)hudText {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hudText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
}

//显示 刷新按钮
-(void)showReloadButton {
    if (!self.selfReloadBtn) {
        self.selfReloadBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 50)/2, (self.view.frame.size.height - 50 - 70)/2, 50, 50)];
        UIImage* img = [UIImage imageNamed:@"defaultRefresh"];
        UIImage* tintImg = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.selfReloadBtn setTintColor:[UIColor grayColor]];
        [self.selfReloadBtn setImage:tintImg forState:UIControlStateNormal];
        [self.selfReloadBtn addTarget:self action:@selector(clickedSelfReloadButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.selfReloadBtn];
        self.selfReloadBtn.hidden = YES;
    }
    self.selfReloadBtn.hidden = NO;
    [self.view bringSubviewToFront:self.selfReloadBtn];
}

//隐藏 刷新按钮
-(void)hideReloadButton {
    self.selfReloadBtn.hidden = YES;
}

//点击 刷新按钮
-(void)clickedSelfReloadButton:(UIButton* )sender {
    [self hideReloadButton];
    
}

//显示 无数据
-(void)showEmptyLabelWithText:(NSString* )emptyText {
    if (!self.emptyLabel) {
        self.emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height - 70 - 50)/2, self.view.frame.size.width, 50)];
        self.emptyLabel.center = self.view.center;
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.textColor = [UIColor grayColor];
        self.emptyLabel.font = [UIFont systemFontOfSize:18];
        self.emptyLabel.numberOfLines = 0;
        self.emptyLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.view addSubview:self.emptyLabel];
        self.emptyLabel.hidden = YES;
    }
    NSString* str = @"空空如也";
    if (emptyText != nil) {
        str = emptyText;
    }
    CGSize labSize = [self.emptyLabel sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
    self.emptyLabel.frame = CGRectMake(0, (self.view.frame.size.height - 70 - labSize.height)/2, self.view.frame.size.width, labSize.height);
    self.emptyLabel.text = str;
    self.emptyLabel.hidden = NO;
    [self.view bringSubviewToFront:self.emptyLabel];
}

//显示 无数据 指定frame
-(void)showEmptyLabelWithCenterPoint:(CGPoint )centerPoint text:(NSString* )emptyText {
    if (!self.emptyLabel) {
        self.emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height - 70 - 50)/2, self.view.frame.size.width, 50)];
        self.emptyLabel.center = self.view.center;
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.textColor = [UIColor grayColor];
        self.emptyLabel.font = [UIFont systemFontOfSize:18];
        self.emptyLabel.numberOfLines = 0;
        self.emptyLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.view addSubview:self.emptyLabel];
        self.emptyLabel.hidden = YES;
    }
    NSString* str = @"空空如也";
    if (emptyText != nil) {
        str = emptyText;
    }
    CGSize labSize = [self.emptyLabel sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
    self.emptyLabel.frame = CGRectMake(0, centerPoint.y - labSize.height / 2, self.view.frame.size.width, labSize.height);
    self.emptyLabel.text = str;
    self.emptyLabel.hidden = NO;
    [self.view bringSubviewToFront:self.emptyLabel];
}

//隐藏 无数据
-(void)hideEmptyLabel {
    self.emptyLabel.hidden = YES;
}

-(void)dealloc {
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
