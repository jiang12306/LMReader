//
//  LMRootViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRootViewController.h"
#import "LMBaseTabBarController.h"
#import "LMTool.h"
#import "LMFirstLaunchViewController.h"

@interface LMRootViewController ()

@end

@implementation LMRootViewController

static LMRootViewController *sharedVC;
static dispatch_once_t onceToken;

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (sharedVC == nil) {
            sharedVC = [super allocWithZone:zone];
            
        }
    });
    return sharedVC;
}

-(id)copyWithZone:(NSZone *)zone {
    return sharedVC;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return sharedVC;
}

+(instancetype)sharedRootViewController {
    return [[self alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self exchangeLaunchState:[LMTool isFirstLaunch]];
    
}

-(void)exchangeLaunchState:(BOOL)isFirstLaunch {
    BOOL isContain = NO;
    if (isFirstLaunch) {//第一次启动
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[LMFirstLaunchViewController class]]) {
                isContain = YES;
                break;
            }else if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
        if (!isContain) {
            LMFirstLaunchViewController* firstLaunchVC = [[LMFirstLaunchViewController alloc]init];
            [self addChildViewController:firstLaunchVC];
            [self.view addSubview:firstLaunchVC.view];
        }
    }else {
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
                isContain = YES;
                break;
            }else if ([vc isKindOfClass:[LMFirstLaunchViewController class]]) {
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
        if (!isContain) {
            LMBaseTabBarController* barController = [[LMBaseTabBarController alloc]init];
            [self addChildViewController:barController];
            [self.view addSubview:barController.view];
        }
    }
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
