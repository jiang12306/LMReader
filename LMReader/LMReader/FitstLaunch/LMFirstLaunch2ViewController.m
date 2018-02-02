//
//  LMFirstLaunch2ViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFirstLaunch2ViewController.h"
#import "LMTool.h"

@interface LMFirstLaunch2ViewController ()

@property (nonatomic, strong) UIButton* maleBtn;//男 按钮
@property (nonatomic, strong) UIButton* femaleBtn;//女 按钮
@property (nonatomic, strong) NSMutableArray* btnArray;//按钮 数组

@end

@implementation LMFirstLaunch2ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat space = 10;
    CGFloat btnWidth = (self.view.frame.size.width - space*4)/3;
    
    CGFloat originalY = 30;
    if ([[LMTool deviceType] isEqualToString:@"6"]) {
        originalY = 60;
    }else if ([[LMTool deviceType] isEqualToString:@"6p"]) {
        originalY = 80;
    }else if ([[LMTool deviceType] isEqualToString:@"x"]) {
        originalY = 120;
    }
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(0, originalY, self.view.frame.size.width, 40)];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.font = [UIFont systemFontOfSize:20];
    lab1.text = @"选择您的读书类型";
    [self.view addSubview:lab1];
    
    UILabel* lab2 = [[UILabel alloc]initWithFrame:CGRectMake(0, lab1.frame.origin.y + lab1.frame.size.height, self.view.frame.size.width, 30)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.font = [UIFont systemFontOfSize:16];
    lab2.text = @"我们将为您推荐更适合您的小说";
    [self.view addSubview:lab2];
    
    self.maleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, 40)];
    self.maleBtn.layer.cornerRadius = 5;
    self.maleBtn.layer.masksToBounds = YES;
    self.maleBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.maleBtn.layer.borderWidth = 2;
    self.maleBtn.selected = NO;
    self.maleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.maleBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [self.maleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.maleBtn setTitle:@"男生" forState:UIControlStateNormal];
    [self.maleBtn addTarget:self action:@selector(clickedMaleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.maleBtn.center = CGPointMake(self.view.center.x - btnWidth/2 - space, lab2.frame.origin.y + lab2.frame.size.height + 40);
    [self.view addSubview:self.maleBtn];
    
    self.femaleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, 40)];
    self.femaleBtn.layer.cornerRadius = 5;
    self.femaleBtn.layer.masksToBounds = YES;
    self.femaleBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.femaleBtn.layer.borderWidth = 2;
    self.femaleBtn.selected = NO;
    self.femaleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.femaleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.femaleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.femaleBtn setTitle:@"女生" forState:UIControlStateNormal];
    [self.femaleBtn addTarget:self action:@selector(clickedFemaleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.femaleBtn.center = CGPointMake(self.maleBtn.center.x + btnWidth + space, self.maleBtn.center.y);
    [self.view addSubview:self.femaleBtn];
    
    self.btnArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 9; i ++) {
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(space + (i%3)*(btnWidth + space), self.maleBtn.frame.origin.y + self.maleBtn.frame.size.height + space*2 + (i/3)*(btnWidth + space), btnWidth, btnWidth)];//spaceX + (i%3)*(btnWidth + space)
        btn.backgroundColor = [UIColor greenColor];
        btn.selected = NO;
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(clickedInterestButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(btn.frame.size.width - 20, btn.frame.size.height - 20, 20, 20)];
        iv.image = [UIImage imageNamed:@"interestButton"];
        iv.tag = i + 1;
        [btn addSubview:iv];
        
        [self.view addSubview:btn];
        [self.btnArray addObject:btn];
    }
    
    UILabel* lab3 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.maleBtn.frame.origin.y + self.maleBtn.frame.size.height + (btnWidth + space)*3 + 20, self.view.frame.size.width, 30)];
    lab3.textAlignment = NSTextAlignmentCenter;
    lab3.textColor = [UIColor grayColor];
    lab3.font = [UIFont systemFontOfSize:16];
    lab3.text = @"可多选";
    [self.view addSubview:lab3];
}

//男 按钮
-(void)clickedMaleButton:(UIButton* )sender {
    if (self.maleBtn.selected) {
        self.maleBtn.selected = NO;
        self.maleBtn.backgroundColor = [UIColor whiteColor];
    }else {
        self.maleBtn.selected = YES;
        self.maleBtn.backgroundColor = THEMECOLOR;
        self.femaleBtn.selected = NO;
        self.femaleBtn.backgroundColor = [UIColor whiteColor];
    }
    
    [self startBlockDictionary];
}

//女 按钮
-(void)clickedFemaleButton:(UIButton* )sender {
    if (self.femaleBtn.selected) {
        self.femaleBtn.selected = NO;
        self.femaleBtn.backgroundColor = [UIColor whiteColor];
    }else {
        self.femaleBtn.selected = YES;
        self.femaleBtn.backgroundColor = [UIColor redColor];
        self.maleBtn.selected = NO;
        self.maleBtn.backgroundColor = [UIColor whiteColor];
    }
    
    [self startBlockDictionary];
}

//选择兴趣
-(void)clickedInterestButton:(UIButton* )sender {
    for (UIView* vi in sender.subviews) {
        if ([vi isKindOfClass:[UIImageView class]]) {
            UIImageView* iv = (UIImageView* )vi;
            
            if (sender.selected) {
                sender.selected = NO;
                
                iv.image = [UIImage imageNamed:@"interestButton"];
            }else {
                sender.selected = YES;
                iv.image = [UIImage imageNamed:@"interestButton_Selected"];
            }
            break;
        }
    }
    
    [self startBlockDictionary];
}

//反向传值
-(void)startBlockDictionary {
    if (self.maleBtn.selected == YES) {
        
    }
    if (self.femaleBtn.selected == YES) {
        
    }
    for (UIButton* btn in self.btnArray) {
        if (btn.selected) {
            
        }
    }
    
    self.callBlock(@{});
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
