//
//  LMBaseNavigationController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseNavigationController.h"

@interface LMBaseNavigationController ()

@end

@implementation LMBaseNavigationController

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
//        self.navigationBar.barTintColor = [UIColor whiteColor];//背景颜色
//        self.navigationBar.tintColor = [UIColor blackColor];//字体颜色
        
        CGRect screenRect = [UIScreen mainScreen].bounds;
        UIImage* img = [self createImageWithColor:[UIColor whiteColor] size:CGSizeMake(screenRect.size.width, 100)];
        [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        
        
        //导航栏底部分隔线
//        [self.navigationBar setClipsToBounds:YES];
        
//        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    }
    return self;
}

-(UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        UIImage* image = [UIImage imageNamed:@"navigationItem_Back"];
        UIImage* tintImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton* leftButton = [[UIButton alloc]initWithFrame:vi.frame];
        [leftButton setTintColor:UIColorFromRGB(0x656565)];
        [leftButton setImage:tintImage forState:UIControlStateNormal];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 13, 5, 15)];
        [leftButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        [vi addSubview:leftButton];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:vi];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
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
