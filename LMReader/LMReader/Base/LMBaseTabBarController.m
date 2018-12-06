//
//  LMBaseTabBarController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTabBarController.h"
#import "LMBaseNavigationController.h"
#import "LMBookShelfViewController.h"
#import "LMChoiceViewController.h"
#import "LMBookStoreViewController.h"
#import "LMProfileViewController.h"
#import "UITabBar+LMBadge.h"

@interface LMBaseTabBarController ()

@end

@implementation LMBaseTabBarController

-(instancetype)init {
    self = [super init];
    if (self) {
        NSArray* titleArr = @[@"书架", @"精选", @"书城", @"我的"];
        NSArray* imagesArr = @[@"tabBar_BookShelf", @"tabBar_Choice", @"tabBar_BookStore", @"tabBar_Profile"];
        NSArray* selectedImagesArr = @[@"tabBar_BookShelf_Selected", @"tabBar_Choice_Selected", @"tabBar_BookStore_Selected", @"tabBar_Profile_Selected"];
        
        LMBookShelfViewController* shelfVC = [[LMBookShelfViewController alloc]init];
        UIImage* shelfImage = [UIImage imageNamed:imagesArr[0]];
        UIImage* shelfSelectedImage = [UIImage imageNamed:selectedImagesArr[0]];
        shelfVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[0] image:shelfImage selectedImage:shelfSelectedImage];
        shelfVC.tabBarItem.tag = 0;
        
        LMChoiceViewController* choiceVC = [[LMChoiceViewController alloc]init];
        UIImage* choiceImage = [UIImage imageNamed:imagesArr[1]];
        UIImage* choiceSelectedImage = [UIImage imageNamed:selectedImagesArr[1]];
        choiceVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[1] image:choiceImage selectedImage:choiceSelectedImage];
        choiceVC.tabBarItem.tag = 1;
        
        LMBookStoreViewController* bookStoreVC = [[LMBookStoreViewController alloc]init];
        UIImage* bookStoreImage = [UIImage imageNamed:imagesArr[2]];
        UIImage* bookStoreSelectedImage = [UIImage imageNamed:selectedImagesArr[2]];
        bookStoreVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[2] image:bookStoreImage selectedImage:bookStoreSelectedImage];
        bookStoreVC.tabBarItem.tag = 2;
        
        LMProfileViewController* profileVC = [[LMProfileViewController alloc]init];
        UIImage* profileImage = [UIImage imageNamed:imagesArr[3]];
        UIImage* profileSelectedImage = [UIImage imageNamed:selectedImagesArr[3]];
        profileVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[3] image:profileImage selectedImage:profileSelectedImage];
        profileVC.tabBarItem.tag = 3;
        
        LMBaseNavigationController* shelfNVC = [[LMBaseNavigationController alloc]initWithRootViewController:shelfVC];
        LMBaseNavigationController* choiceNVC = [[LMBaseNavigationController alloc]initWithRootViewController:choiceVC];
        LMBaseNavigationController* bookStoreNVC = [[LMBaseNavigationController alloc]initWithRootViewController:bookStoreVC];
        LMBaseNavigationController* profileNVC = [[LMBaseNavigationController alloc]initWithRootViewController:profileVC];
        
        self.tabBar.tintColor = THEMEORANGECOLOR;
        self.tabBar.translucent = NO;//适配iOS12.1上pop时tabBar错位bug
        self.viewControllers = @[shelfNVC, choiceNVC, bookStoreNVC, profileNVC];
    }
    return self;
}

//显示tabBar红点
-(void)showTabBarItemRedDotWithIndex:(NSInteger)index {
    [self.tabBar showBadgeOnItemIndex:index];
}

//隐藏tabBar红点
-(void)hideTabBarItemRedDotWithIndex:(NSInteger)index {
    [self.tabBar hideBadgeOnItemIndex:index];
}

//获取是否有tabBar红点
-(BOOL)getTabBarItemRedDotWithIndex:(NSInteger)index {
    return [self.tabBar getBadgeOnItemIndex:index];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
