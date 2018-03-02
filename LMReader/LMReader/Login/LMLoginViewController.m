//
//  LMLoginViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMLoginViewController.h"
#import "LMRegisterViewController.h"
#import "LMTool.h"

@interface LMLoginViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* phoneTF;
@property (nonatomic, strong) UITextField* pwdTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"登录";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 15;
    CGFloat labHeight = 30;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:241/255.f alpha:1];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    UILabel* phoneLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, spaceY, 60, labHeight)];
    phoneLab.font = [UIFont systemFontOfSize:16];
    phoneLab.text = @"手机号";
    [self.scrollView addSubview:phoneLab];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(phoneLab.frame.origin.x + phoneLab.frame.size.width + spaceX, phoneLab.frame.origin.y, self.view.frame.size.width - phoneLab.frame.size.width - spaceX * 3, labHeight)];
    self.phoneTF.backgroundColor = [UIColor whiteColor];
    self.phoneTF.layer.cornerRadius = 5;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.scrollView addSubview:self.phoneTF];
    
    UILabel* pwdLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, phoneLab.frame.origin.y + phoneLab.frame.size.height + spaceY, 60, labHeight)];
    phoneLab.font = [UIFont systemFontOfSize:16];
    pwdLab.text = @"密码";
    [self.scrollView addSubview:pwdLab];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(self.phoneTF.frame.origin.x, pwdLab.frame.origin.y, self.phoneTF.frame.size.width, self.phoneTF.frame.size.height)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.keyboardType = UIKeyboardTypeEmailAddress;
    self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTF.secureTextEntry = YES;
    [self.scrollView addSubview:self.pwdTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, pwdLab.frame.origin.y + pwdLab.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, 35)];
    self.sendBtn.backgroundColor = THEMECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    UIButton* registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + spaceY, 80, 20)];
    NSMutableAttributedString* registerStr = [[NSMutableAttributedString alloc]initWithString:@"手机号注册" attributes:@{NSForegroundColorAttributeName : THEMECOLOR, NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [registerBtn setAttributedTitle:registerStr forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(clickedRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:registerBtn];
    
    UIButton* forgetPwdBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - spaceX - 60, registerBtn.frame.origin.y, 60, 20)];
    NSMutableAttributedString* forgetPwdStr = [[NSMutableAttributedString alloc]initWithString:@"忘记密码" attributes:@{NSForegroundColorAttributeName : THEMECOLOR, NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [forgetPwdBtn setAttributedTitle:forgetPwdStr forState:UIControlStateNormal];
    [forgetPwdBtn addTarget:self action:@selector(clickedForgetPwdButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:forgetPwdBtn];
}

//登录
-(void)clickedSendButton:(UIButton* )sender {
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (phoneStr.length == 0) {
        [self showMBProgressHUDWithText:@"手机号不能为空"];
        return;
    }
    if (pwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"密码不能为空"];
        return;
    }
    
    [self showNetworkLoadingView];
    
    RegUserLoginReqBuilder* builder = [RegUserLoginReq builder];
    [builder setU:phoneStr];
    [builder setMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    RegUserLoginReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:19 ReqData:reqData successBlock:^(NSData *successData) {
        [self hideNetworkLoadingView];
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 19) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                RegUserLoginRes* res = [RegUserLoginRes parseFromData:apiRes.body];
                LoginedRegUser* logUser = res.loginedUser;
                NSString* tokenStr = logUser.token;
                if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                    
                    self.userBlock(logUser);
                    
                    //绑定设备与用户
                    [LMTool bindDeviceToUser:logUser];
                    
                    //保存登录用户信息
                    [LMTool saveLoginedRegUser:logUser];
                    
                    //返回
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
            }else {
                [self showMBProgressHUDWithText:@"账号或密码错误"];
            }
        }
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [self showMBProgressHUDWithText:@"网络请求失败"];
        [self hideNetworkLoadingView];
    }];
}

//注册
-(void)clickedRegisterButton:(UIButton* )sender {
    LMRegisterViewController* registerVC = [[LMRegisterViewController alloc]init];
    registerVC.type = LMRegisterTypeNewRegister;
    [self.navigationController pushViewController:registerVC animated:YES];
}

//忘记密码
-(void)clickedForgetPwdButton:(UIButton* )sender {
    LMRegisterViewController* registerVC = [[LMRegisterViewController alloc]init];
    registerVC.type = LMRegisterTypeForgetPassword;
    [self.navigationController pushViewController:registerVC animated:YES];
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
