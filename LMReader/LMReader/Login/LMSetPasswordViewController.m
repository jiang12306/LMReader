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
    
    self.title = @"设置密码";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 20;
    CGFloat labHeight = 40;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.borderWidth = 1;
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTF.secureTextEntry = YES;
    self.pwdTF.placeholder = @" 输入新密码";
    [self.scrollView addSubview:self.pwdTF];
    
    self.conformTF = [[UITextField alloc]initWithFrame:CGRectMake(self.pwdTF.frame.origin.x, self.pwdTF.frame.origin.y + self.pwdTF.frame.size.height + spaceY, self.pwdTF.frame.size.width, self.pwdTF.frame.size.height)];
    self.conformTF.backgroundColor = [UIColor whiteColor];
    self.conformTF.layer.borderWidth = 1;
    self.conformTF.layer.cornerRadius = 5;
    self.conformTF.layer.masksToBounds = YES;
    self.conformTF.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.conformTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.conformTF.secureTextEntry = YES;
    self.conformTF.placeholder = @" 确认新密码";
    [self.scrollView addSubview:self.conformTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.conformTF.frame.origin.y + self.conformTF.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.sendBtn.backgroundColor = THEMEORANGECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

-(void)stopEditing {
    if ([self.pwdTF isFirstResponder]) {
        [self.pwdTF resignFirstResponder];
    }
    if ([self.conformTF isFirstResponder]) {
        [self.conformTF resignFirstResponder];
    }
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
    if (self.type == SmsTypeSmsReg) {
        [builder setReqType:0];
    }else if (self.type == SmsTypeSmsForgotpwd) {
        [builder setReqType:1];
    }else if (self.type == SmsTypeSmsBind) {
        [builder setReqType:2];
    }
    [builder setPhoneNum:self.phoneStr];
    [builder setVcode:self.verifyStr];
    [builder setMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    PhoneNumRegAndResetPwdReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMSetPasswordViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:17 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
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
                        
                        [weakSelf showMBProgressHUDWithText:@"操作成功"];
                        
                        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            if (weakSelf.type == SmsTypeSmsReg) {//新注册用户回到“我的”界面
                                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                            }else if (weakSelf.type == SmsTypeSmsForgotpwd) {//忘记密码，回到“我的”界面
                                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                            }else if (weakSelf.type == SmsTypeSmsBind) {//绑定手机号，然后修改密码，回到“我的”界面
                                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                            }
                        });
                        
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"操作失败"];
                    }
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf hideNetworkLoadingView];
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
