//
//  LMFirstLaunchViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFirstLaunchViewController.h"
#import "LMRootViewController.h"
#import "LMFirstLaunch1ViewController.h"
#import "LMFirstLaunch2ViewController.h"
#import "LMFirstLaunch3ViewController.h"
#import "LMTool.h"
#import "LMDatabaseTool.h"

@interface LMFirstLaunchViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) NSMutableDictionary* interestDic;//性别、感兴趣的小说类型
@property (nonatomic, strong) NSMutableArray* dataArr;//服务端根据兴趣返回的5本小说

@end

@implementation LMFirstLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (@available(iOS 9.0, *)) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    }
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    
    LMFirstLaunch1ViewController* launch1 = [[LMFirstLaunch1ViewController alloc]init];
    [self addChildViewController:launch1];
    [self.scrollView addSubview:launch1.view];
    
    __weak LMFirstLaunchViewController* weakSelf = self;
    
    LMFirstLaunch2ViewController* launch2 = [[LMFirstLaunch2ViewController alloc]init];
    launch2.callBlock = ^(NSDictionary *blockDic) {
        if (blockDic != nil && ![blockDic isKindOfClass:[NSNull class]] && blockDic.count > 0) {
            weakSelf.interestDic = [NSMutableDictionary dictionaryWithDictionary:blockDic];
        }
        //将兴趣传值过来
    };
    [self addChildViewController:launch2];
    launch2.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView addSubview:launch2.view];
    
    LMFirstLaunch3ViewController* launch3 = [[LMFirstLaunch3ViewController alloc]init];
    launch3.callBlock = ^(BOOL didClick, NSArray* bookArr) {
        if (didClick) {
            if (bookArr != nil &&![bookArr isKindOfClass:[NSNull class]] && bookArr.count > 0) {
                
                weakSelf.dataArr = [NSMutableArray arrayWithArray:bookArr];
            }
            [weakSelf didLaunch];
        }
    };
    [self addChildViewController:launch3];
    launch3.view.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView addSubview:launch3.view];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    CGFloat pageCenterY = self.view.frame.size.height - 20;
    if ([LMTool isIPhoneX]) {
        pageCenterY -= 20;
    }
    self.pageControl.center = CGPointMake(self.view.frame.size.width/2, pageCenterY);
    [self.view addSubview:self.pageControl];
    
}

//隐藏状态栏
//-(BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //首先通过tag值得到pageControl
    //page的计算方法为scrollView的偏移量除以屏幕的宽度即为第几页。
    int page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
    self.pageControl.currentPage = page;
    if (page == 2) {
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[LMFirstLaunch3ViewController class]]) {
                LMFirstLaunch3ViewController* launch3VC = (LMFirstLaunch3ViewController* )vc;
                [launch3VC loadInterestDataWithDic:[self.interestDic mutableCopy]];
            }
        }
    }
}

-(void)didLaunch {
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    
    //测试 删除 表
//    [tool deleteBookShelfTable];
//    [tool deleteSourceTable];
//    [tool deleteLastChapterTable];
    
    [tool createBookShelfTable];
    [tool createSourceTable];
    [tool createLastChapterTable];
    
    if (self.dataArr != nil && ![self.dataArr isKindOfClass:[NSNull class]] && self.dataArr.count > 0) {
        
        [tool saveBooksWithArray:self.dataArr];
    }
    
    
    [[LMRootViewController sharedRootViewController] exchangeLaunchState:NO];
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
