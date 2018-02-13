//
//  LMFirstLaunch2ViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFirstLaunch2ViewController.h"
#import "LMTool.h"
#import "Ftbook.pb.h"
#import "LMNetworkTool.h"

@interface LMFirstLaunch2ViewController ()

@property (nonatomic, strong) UIButton* maleBtn;//男 按钮
@property (nonatomic, strong) UIButton* femaleBtn;//女 按钮
@property (nonatomic, strong) UIScrollView* scrollView;//类型 scrollView
@property (nonatomic, strong) NSMutableArray* btnDataArray;//按钮 数据源 数组
@property (nonatomic, strong) NSMutableArray* btnArray;//按钮 数组
@property (nonatomic, strong) UILabel* infoLab;//可多选 label

@end

@implementation LMFirstLaunch2ViewController

#define maleColor [UIColor colorWithRed:40/255.f green:147/255.f blue:232/255.f alpha:1]
#define femaleColor [UIColor colorWithRed:210/255.f green:17/255.f blue:68/255.f alpha:1]
#define btnGrayColor [UIColor colorWithRed:214/255.f green:214/255.f blue:214/255.f alpha:1]
#define btnWhiteColor [UIColor whiteColor]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat space = 10;
    CGFloat btnWidth = (self.view.frame.size.width - space*4)/3;
    
    CGFloat originalY = 30;
//    if ([[LMTool deviceType] isEqualToString:@"6"]) {
//        originalY = 60;
//    }else if ([[LMTool deviceType] isEqualToString:@"6p"]) {
//        originalY = 80;
//    }else if ([[LMTool deviceType] isEqualToString:@"x"]) {
//        originalY = 120;
//    }
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
    self.maleBtn.layer.borderColor = btnGrayColor.CGColor;
    self.maleBtn.layer.borderWidth = 1;
    self.maleBtn.selected = NO;
    self.maleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.maleBtn setTitleColor:maleColor forState:UIControlStateNormal];
    [self.maleBtn setTitleColor:btnWhiteColor forState:UIControlStateSelected];
    [self.maleBtn setTitle:@"男生" forState:UIControlStateNormal];
    [self.maleBtn addTarget:self action:@selector(clickedMaleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.maleBtn.center = CGPointMake(self.view.center.x - btnWidth/2 - space, lab2.frame.origin.y + lab2.frame.size.height + 40);
    [self.view addSubview:self.maleBtn];
    
    self.femaleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, 40)];
    self.femaleBtn.layer.cornerRadius = 5;
    self.femaleBtn.layer.masksToBounds = YES;
    self.femaleBtn.layer.borderColor = btnGrayColor.CGColor;
    self.femaleBtn.layer.borderWidth = 1;
    self.femaleBtn.selected = NO;
    self.femaleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.femaleBtn setTitleColor:femaleColor forState:UIControlStateNormal];
    [self.femaleBtn setTitleColor:btnWhiteColor forState:UIControlStateSelected];
    [self.femaleBtn setTitle:@"女生" forState:UIControlStateNormal];
    [self.femaleBtn addTarget:self action:@selector(clickedFemaleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.femaleBtn.center = CGPointMake(self.maleBtn.center.x + btnWidth + space, self.maleBtn.center.y);
    [self.view addSubview:self.femaleBtn];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.femaleBtn.frame.origin.y + self.femaleBtn.frame.size.height + space*2, self.view.frame.size.width, self.view.frame.size.height - self.maleBtn.frame.origin.y - self.maleBtn.frame.size.height - space*2 - 40 - 40)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.scrollView];
    
    self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.scrollView.frame.origin.y + self.scrollView.frame.size.height + space, self.view.frame.size.width, 20)];
    self.infoLab.textAlignment = NSTextAlignmentCenter;
    self.infoLab.textColor = [UIColor grayColor];
    self.infoLab.font = [UIFont systemFontOfSize:16];
    self.infoLab.text = @"可多选";
    [self.view addSubview:self.infoLab];
    self.infoLab.hidden = YES;
    
    self.btnArray = [NSMutableArray array];
    self.btnDataArray = [NSMutableArray array];
    
//    [self.btnDataArray addObjectsFromArray:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34"]];
    
}

//男 按钮
-(void)clickedMaleButton:(UIButton* )sender {
    if (self.maleBtn.selected) {
        //取消选中
        self.maleBtn.selected = NO;
        self.maleBtn.backgroundColor = btnWhiteColor;
    }else {
        //选中
        self.maleBtn.selected = YES;
        self.maleBtn.backgroundColor = THEMECOLOR;
        self.femaleBtn.selected = NO;
        self.femaleBtn.backgroundColor = btnWhiteColor;
    }
    //反向传值
    [self startBlockDictionary];
    
    //加载小说类型 列表
    [self clickedSexButton:sender];
}

//女 按钮
-(void)clickedFemaleButton:(UIButton* )sender {
    if (self.femaleBtn.selected) {
        //取消选中
        self.femaleBtn.selected = NO;
        self.femaleBtn.backgroundColor = btnWhiteColor;
    }else {
        //选中
        self.femaleBtn.selected = YES;
        self.femaleBtn.backgroundColor = femaleColor;
        self.maleBtn.selected = NO;
        self.maleBtn.backgroundColor = btnWhiteColor;
    }
    //反向传值
    [self startBlockDictionary];
    
    //加载小说类型 列表
    [self clickedSexButton:sender];
}

//选择性别
-(void)clickedSexButton:(UIButton* )sender {
    [self.btnDataArray removeAllObjects];
    [self.btnArray removeAllObjects];
    for (UIView* vi in self.scrollView.subviews) {
        [vi removeFromSuperview];
    }
    self.infoLab.hidden = YES;
    
    GenderType genderType = GenderTypeGenderUnknown;
    if (sender == self.maleBtn && self.maleBtn.selected) {
        genderType = GenderTypeGenderMale;
    }else if (sender == self.femaleBtn && self.femaleBtn.selected) {
        genderType = GenderTypeGenderFemale;
    }else {
        return;
    }
    
    [self showNetworkLoadingView];//loadingView
    
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:genderType];
    FirstBookTypeReq* req = [builder build];
    
    NSData* reqData = [req data];
    
    [[LMNetworkTool sharedNetworkTool] postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 1) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                    NSArray* arr = res.bookType;
                    
                    if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                        [self.btnDataArray addObjectsFromArray:arr];
                        //
                        [self setupInterestButton];
                        
                        [self hideNetworkLoadingView];
                    }else {
                        [self hideNetworkLoadingView];
                    }
                }else {
                    [self hideNetworkLoadingView];
                }
            }else {
                [self hideNetworkLoadingView];
            }
        }else {
            [self hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

//加载 小说类型 视图
-(void)setupInterestButton {
    if (self.btnDataArray == nil || self.btnDataArray.count == 0) {
        return;
    }
    
    CGFloat space = 10;
    CGFloat btnWidth = self.maleBtn.frame.size.width;
    CGFloat btnHeight = self.maleBtn.frame.size.height;
//    if (self.btnDataArray.count < 3) {
//        btnWidth = (self.view.frame.size.width - space*(self.btnDataArray.count + 1))/self.btnDataArray.count;
//    }
    for (NSInteger i = 0; i < self.btnDataArray.count; i ++) {
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(space + (i%3)*(btnWidth + space), (i/3)*(btnHeight + space), btnWidth, btnHeight)];
        btn.backgroundColor = btnWhiteColor;
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = btnGrayColor.CGColor;
        btn.layer.borderWidth = 1;
        btn.selected = NO;
        btn.tag = i + 1;
        [btn setTitle:[self.btnDataArray objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:btnGrayColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickedInterestButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:btn];
        [self.btnArray addObject:btn];
    }
    
    CGRect scrollRect = self.scrollView.frame;
    CGFloat contentHeight = (self.btnDataArray.count/3)*(btnHeight + space);
    if (self.btnDataArray.count % 3 != 0) {
        contentHeight += btnHeight;
    }
    if (scrollRect.size.height < contentHeight) {
        self.scrollView.contentSize = CGSizeMake(0, contentHeight);
    }else {
        self.scrollView.contentSize = CGSizeMake(0, 0);
    }
    
    self.infoLab.hidden = NO;
}

//选择兴趣
-(void)clickedInterestButton:(UIButton* )sender {
    if (sender.selected) {
        //取消选中
        sender.selected = NO;
        sender.layer.borderColor = btnGrayColor.CGColor;
        
    }else {
        //选中
        sender.selected = YES;
        if (self.maleBtn.selected) {
            sender.layer.borderColor = maleColor.CGColor;
        }else {
            if (self.femaleBtn.selected) {
                sender.layer.borderColor = femaleColor.CGColor;
            }
        }
    }
    
    [self startBlockDictionary];
}

//反向传值
-(void)startBlockDictionary {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (self.maleBtn.selected == YES) {
        [dic setObject:@1 forKey:@"male"];
    }else {
        [dic setObject:@0 forKey:@"male"];
    }
    if (self.femaleBtn.selected == YES) {
        [dic setObject:@1 forKey:@"female"];
    }else {
        [dic setObject:@0 forKey:@"female"];
    }
    NSMutableArray* nameArr = [NSMutableArray array];
    for (UIButton* btn in self.btnArray) {
        if (btn.selected) {
            NSInteger index = [self.btnArray indexOfObject:btn];
            NSString* nameStr = [self.btnDataArray objectAtIndex:index];
            
            [nameArr addObject:nameStr];
        }
    }
    if (nameArr != nil && nameArr.count > 0) {
        [dic setObject:nameArr forKey:@"interest"];
    }
    
    self.callBlock(dic);
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
