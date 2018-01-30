//
//  LMFirstLaunchViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFirstLaunchViewController.h"
#import "LMRootViewController.h"

@interface LMFirstLaunchViewController ()

@end

@implementation LMFirstLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clcikedButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:btn];
}

-(void)clcikedButton:(UIButton* )sender {
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
