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
#import "LMBaseNavigationController.h"
#import "LMLaunchDetailViewController.h"
#import "LMSearchViewController.h"
#import "LMBookDetailViewController.h"
#import "LMBaseAlertView.h"

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
    return [[LMRootViewController alloc]init];
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

//更改当前显示vc
-(void)setCurrentViewControllerIndex:(NSInteger)index {
    NSInteger targetIndex = index;
    if (index > 3) {
        targetIndex = 0;
    }
    LMBaseTabBarController* tabBarController;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
            tabBarController = (LMBaseTabBarController* )vc;
            break;
        }
    }
    if (tabBarController && targetIndex < tabBarController.viewControllers.count) {
        tabBarController.selectedIndex = targetIndex;
    }
}

/** 回到TabBarController当前显示vc
 *  @param index 当前item的角标 0：书架  1：精选   2：书城  3：我的
 */
-(void)backToTabBarControllerWithViewControllerIndex:(NSInteger )index {
    [self openViewControllerCalss:nil paramString:nil];
    [self setCurrentViewControllerIndex:index];
}

//跳转至vc
-(void)openViewControllerCalss:(NSString* )classString paramString:(NSString* )paramString {
    LMBaseTabBarController* tabBarController;
    NSArray* windowArr = [UIApplication sharedApplication].windows;
    for (NSInteger i = 0; i < windowArr.count; i ++) {
        UIWindow* currentWindow = [windowArr objectAtIndex:i];
        NSArray* viewsArr = currentWindow.subviews;
        for (UIView* vi in viewsArr) {
            if ([vi isKindOfClass:[LMBaseAlertView class]]) {
                [vi removeFromSuperview];
            }
        }
    }
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
            tabBarController = (LMBaseTabBarController* )vc;
            for (UIViewController* vc in tabBarController.viewControllers) {
                LMBaseNavigationController* nvc = (LMBaseNavigationController* )vc;
                
                NSArray* vcArr = nvc.viewControllers;
                for (NSInteger i = vcArr.count - 1; i >= 0; i --) {
                    UIViewController* vc = [vcArr objectAtIndex:i];
                    if (vc.presentedViewController) {
                        [vc dismissViewControllerAnimated:NO completion:nil];
                    }else {
                        [vc.navigationController popViewControllerAnimated:NO];
                    }
                }
            }
            break;
        }
    }
    if (tabBarController.viewControllers.count > 0) {
        if (classString == nil || [classString isKindOfClass:[NSNull class]] || classString.length == 0) {
            return;
        }
        Class class = NSClassFromString(classString);
        if (class) {
            if ([classString isEqualToString:@"LMLaunchDetailViewController"]) {
                [self setCurrentViewControllerIndex:0];
                LMLaunchDetailViewController* vc = [class new];
                if (paramString != nil && ![paramString isKindOfClass:[NSNull class]]) {
                    vc.urlString = paramString;
                }
                LMBaseNavigationController* bookShelfNVC = [tabBarController.viewControllers objectAtIndex:0];
                [bookShelfNVC pushViewController:vc animated:YES];
                
            }else if ([classString isEqualToString:@"LMChoiceViewController"]) {
                [self setCurrentViewControllerIndex:1];
            }else if ([classString isEqualToString:@"LMSearchViewController"]) {
                [self setCurrentViewControllerIndex:0];
                LMSearchViewController* vc = [class new];
                LMBaseNavigationController* bookShelfNVC = [tabBarController.viewControllers objectAtIndex:0];
                [bookShelfNVC pushViewController:vc animated:YES];
            }else if ([classString isEqualToString:@"LMBookDetailViewController"]) {
                [self setCurrentViewControllerIndex:0];
                LMBookDetailViewController* vc = [class new];
                vc.bookId = paramString.intValue;
                LMBaseNavigationController* bookShelfNVC = [tabBarController.viewControllers objectAtIndex:0];
                [bookShelfNVC pushViewController:vc animated:YES];
            }
        }
    }
}

//设置角标红点
-(void)setupShowRedDot:(BOOL)showRedDot index:(NSInteger)index {
    NSInteger targetIndex = index;
    if (index > 3) {
        targetIndex = 0;
    }
    LMBaseTabBarController* tabBarController;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
            tabBarController = (LMBaseTabBarController* )vc;
            break;
        }
    }
    if (tabBarController && targetIndex < tabBarController.viewControllers.count) {
        if (showRedDot) {
            [tabBarController showTabBarItemRedDotWithIndex:index];
        }else {
            [tabBarController hideTabBarItemRedDotWithIndex:index];
        }
    }
}

//获取是否有角标红点
-(BOOL)getShowRedDotWithIndex:(NSInteger)index {
    NSInteger targetIndex = index;
    if (index > 3) {
        targetIndex = 0;
    }
    LMBaseTabBarController* tabBarController;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
            tabBarController = (LMBaseTabBarController* )vc;
            break;
        }
    }
    if (tabBarController && targetIndex < tabBarController.viewControllers.count) {
        return [tabBarController getTabBarItemRedDotWithIndex:index];
    }
    return NO;
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
