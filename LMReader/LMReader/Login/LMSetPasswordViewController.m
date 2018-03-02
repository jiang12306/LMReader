//
//  LMSetPasswordViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSetPasswordViewController.h"
#import "LMTool.h"

@interface LMSetPasswordViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* pwdTF;
@property (nonatomic, strong) UITextField* conformTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"设置密码";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 15;
    CGFloat labHeight = 30;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:241/255.f alpha:1];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    UILabel* pwdLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, spaceY, 90, labHeight)];
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
    NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr2 = [self.conformTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (pwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"请输入密码"];
        return;
    }
    if (pwdStr2.length == 0) {
        [self showMBProgressHUDWithText:@"请确认密码"];
        return;
    }
    if (![pwdStr isEqualToString:pwdStr2]) {
        [self showMBProgressHUDWithText:@"密码不一致"];
        return;
    }
    
    [self showNetworkLoadingView];
    
    PhoneNumRegAndResetPwdReqBuilder* builder = [PhoneNumRegAndResetPwdReq builder];
    if (self.type == LMRegisterTypeNewRegister) {
        [builder setReqType:0];
    }else {
        [builder setReqType:1];
    }
    [builder setPhoneNum:self.phoneStr];
    [builder setVcode:self.verifyStr];
    [builder setMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    PhoneNumRegAndResetPwdReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:17 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 17) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                PhoneNumRegAndResetPwdRes* res = [PhoneNumRegAndResetPwdRes parseFromData:apiRes.body];
                LoginedRegUser* logUser = res.loginedUser;
                NSString* tokenStr = logUser.token;
                if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                    
                    //绑定设备与用户
                    [LMTool bindDeviceToUser:logUser];
                    
                    //保存登录用户信息
                    [LMTool saveLoginedRegUser:logUser];
                    
                    if (self.type == LMRegisterTypeNewRegister) {//新注册用户回到“我的”界面
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }else {//修改密码，回到“我的”界面
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    
                }else {
                    [self showMBProgressHUDWithText:@"设置失败"];
                }
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
