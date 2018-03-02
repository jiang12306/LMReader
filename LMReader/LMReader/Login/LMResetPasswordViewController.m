//
//  LMResetPasswordViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMResetPasswordViewController.h"
#import "LMTool.h"

@interface LMResetPasswordViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* oldPwdTF;
@property (nonatomic, strong) UITextField* pwdTF;
@property (nonatomic, strong) UITextField* conformTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"修改密码";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 15;
    CGFloat labHeight = 30;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:241/255.f alpha:1];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    UILabel* oldPwdLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, spaceY, 90, labHeight)];
    oldPwdLab.font = [UIFont systemFontOfSize:16];
    oldPwdLab.text = @"旧密码";
    [self.scrollView addSubview:oldPwdLab];
    
    self.oldPwdTF = [[UITextField alloc]initWithFrame:CGRectMake(oldPwdLab.frame.origin.x + oldPwdLab.frame.size.width + spaceX, oldPwdLab.frame.origin.y, self.view.frame.size.width - oldPwdLab.frame.size.width - spaceX * 3, labHeight)];
    self.oldPwdTF.backgroundColor = [UIColor whiteColor];
    self.oldPwdTF.layer.cornerRadius = 5;
    self.oldPwdTF.layer.masksToBounds = YES;
    self.oldPwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.oldPwdTF.secureTextEntry = YES;
    [self.scrollView addSubview:self.oldPwdTF];
    
    UILabel* pwdLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, oldPwdLab.frame.origin.y + oldPwdLab.frame.size.height + spaceY, 90, labHeight)];
    pwdLab.font = [UIFont systemFontOfSize:16];
    pwdLab.text = @"输入新密码";
    [self.scrollView addSubview:pwdLab];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(pwdLab.frame.origin.x + pwdLab.frame.size.width + spaceX, pwdLab.frame.origin.y, self.view.frame.size.width - pwdLab.frame.size.width - spaceX * 3, labHeight)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTF.secureTextEntry = YES;
    [self.scrollView addSubview:self.pwdTF];
    
    UILabel* conformLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, pwdLab.frame.origin.y + pwdLab.frame.size.height + spaceY, 90, labHeight)];
    conformLab.font = [UIFont systemFontOfSize:16];
    conformLab.text = @"确认新密码";
    [self.scrollView addSubview:conformLab];
    
    self.conformTF = [[UITextField alloc]initWithFrame:CGRectMake(self.pwdTF.frame.origin.x, conformLab.frame.origin.y, self.pwdTF.frame.size.width, self.pwdTF.frame.size.height)];
    self.conformTF.backgroundColor = [UIColor whiteColor];
    self.conformTF.layer.cornerRadius = 5;
    self.conformTF.layer.masksToBounds = YES;
    self.conformTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.conformTF.secureTextEntry = YES;
    [self.scrollView addSubview:self.conformTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, conformLab.frame.origin.y + conformLab.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, 35)];
    self.sendBtn.backgroundColor = THEMECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
}

//
-(void)clickedSendButton:(UIButton* )sender {
    NSString* oldPwdStr = [self.oldPwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr2 = [self.conformTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (oldPwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"请输入旧密码"];
        return;
    }
    if (pwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"请输入新密码"];
        return;
    }
    if (pwdStr2.length == 0) {
        [self showMBProgressHUDWithText:@"请确认新密码"];
        return;
    }
    if (![pwdStr isEqualToString:pwdStr2]) {
        [self showMBProgressHUDWithText:@"密码不一致"];
        return;
    }
    
    [self showNetworkLoadingView];
    
    ResetPwdReqBuilder* builder = [ResetPwdReq builder];
    [builder setOldMd5Pwd:[LMTool MD5ForLower32Bate:oldPwdStr]];
    [builder setNewMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    ResetPwdReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:18 ReqData:reqData successBlock:^(NSData *successData) {
        [self hideNetworkLoadingView];
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 18) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                [self showMBProgressHUDWithText:@"修改成功"];
                
            }else {
                [self showMBProgressHUDWithText:@"修改失败"];
            }
        }
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [self showMBProgressHUDWithText:@"网络请求失败"];
        [self hideNetworkLoadingView];
    }];
    
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
