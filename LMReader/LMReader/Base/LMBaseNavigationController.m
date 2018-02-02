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
        CGRect screenRect = [UIScreen mainScreen].bounds;
        UIImage* img = [self createImageWithColor:THEMECOLOR size:CGSizeMake(screenRect.size.width, 100)];
        [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
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
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 52, 30)];//12,24
        UIImage* image = [UIImage imageNamed:@"navigationItem_Back"];
        UIImage* tintImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton* leftButton = [[UIButton alloc]initWithFrame:vi.frame];
        [leftButton setTintColor:BACKCOLOR];
        [leftButton setImage:tintImage forState:UIControlStateNormal];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 40)];
        [leftButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftButton setTitle:@"返回" forState:UIControlStateNormal];
        [leftButton setTitleColor:BACKCOLOR forState:UIControlStateNormal];
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
