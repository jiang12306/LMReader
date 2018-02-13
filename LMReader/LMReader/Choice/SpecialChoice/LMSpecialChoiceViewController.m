//
//  LMSpecialChoiceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceViewController.h"
#import "LMSpecialChoiceDetailViewController.h"

@interface LMSpecialChoiceViewController ()

@end

@implementation LMSpecialChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"精选专题";
    
    UIButton* testBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 100)];
    testBtn.backgroundColor = [UIColor greenColor];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

-(void)clickedButton:(UIButton* )sender {
    LMSpecialChoiceDetailViewController* choiceDetailVC = [[LMSpecialChoiceDetailViewController alloc]init];
    [self.navigationController pushViewController:choiceDetailVC animated:YES];
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
