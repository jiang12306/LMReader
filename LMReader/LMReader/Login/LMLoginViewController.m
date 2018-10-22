//
//  LMLoginViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMLoginViewController.h"
#import "LMCheckVerifyCodeViewController.h"
#import "LMTool.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LMLoginAgreementView.h"
#import "LMProfileProtocolViewController.h"

@interface LMLoginViewController () <TencentSessionDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* phoneTF;

@property (nonatomic, strong) UIView* passwordView;/**<密码 视图*/
@property (nonatomic, strong) UITextField* pwdTF;

@property (nonatomic, strong) UIView* codeView;/**<验证码 视图*/
@property (nonatomic, strong) UITextField* codeTF;
@property (nonatomic, strong) UIButton* codeBtn;

@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, strong) UIButton* switchBtn;/**<切换至密码登录*/

@property (nonatomic, strong) UIButton* qqBtn;/**<QQ登录*/

@property (nonatomic, strong) UIButton* weChatBtn;/**<WeChat登录*/

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) NSTimer* timer;

@property (nonatomic, strong) TencentOAuth* qqAuth;

@property (nonatomic, strong) LMLoginAgreementView* agreementView;/**<用户隐私协议*/
@property (nonatomic, assign) BOOL agreeResult;/**<用户是否同意*/

@end

@implementation LMLoginViewController

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.timer) {
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.codeBtn.selected = NO;
        self.count = 0;
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    
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
    
    UIImageView* phoneIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    phoneIV.image = [UIImage imageNamed:@"register_Avator"];
    
    UIView* phoneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labHeight, labHeight)];
    [phoneView addSubview:phoneIV];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.phoneTF.placeholder = @"手机号";
    self.phoneTF.backgroundColor = [UIColor whiteColor];
    self.phoneTF.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.phoneTF.layer.borderWidth = 1;
    self.phoneTF.layer.cornerRadius = 5;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneTF.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTF.leftView = phoneView;
    [self.scrollView addSubview:self.phoneTF];
    
    self.codeView = [[UIView alloc]initWithFrame:CGRectMake(0, self.phoneTF.frame.origin.y + self.phoneTF.frame.size.height + spaceY, self.view.frame.size.width, labHeight)];
    [self.view addSubview:self.codeView];
    
    self.codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.codeView.frame.size.width - spaceX - 80, 0, 80, labHeight)];
    self.codeBtn.layer.cornerRadius = 5;
    self.codeBtn.layer.masksToBounds = YES;
    self.codeBtn.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.codeBtn.layer.borderWidth = 1;
    self.codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeBtn setTitleColor:[UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1] forState:UIControlStateNormal];
    [self.codeBtn addTarget:self action:@selector(clickedCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    self.codeBtn.selected = NO;
    [self.codeView addSubview:self.codeBtn];
    
    self.codeTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, self.codeBtn.frame.origin.y, self.codeView.frame.size.width - self.codeBtn.frame.size.width - spaceX * 3, self.phoneTF.frame.size.height)];
    self.codeTF.backgroundColor = [UIColor whiteColor];
    self.codeTF.layer.borderWidth = 1;
    self.codeTF.layer.cornerRadius = 5;
    self.codeTF.layer.masksToBounds = YES;
    self.codeTF.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.codeTF.placeholder = @" 验证码";
    [self.codeView addSubview:self.codeTF];
    
    self.passwordView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, self.codeView.frame.origin.y, self.view.frame.size.width, labHeight)];
    [self.view addSubview:self.passwordView];
    
    UIImageView* pwdIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    pwdIV.image = [UIImage imageNamed:@"register_Password"];
    
    UIView* pwdView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labHeight, labHeight)];
    [pwdView addSubview:pwdIV];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, 0, self.phoneTF.frame.size.width, self.phoneTF.frame.size.height)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.borderWidth = 1;
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.pwdTF.keyboardType = UIKeyboardTypeEmailAddress;
    self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTF.leftViewMode = UITextFieldViewModeAlways;
    self.pwdTF.leftView = pwdView;
    self.pwdTF.secureTextEntry = YES;
    self.pwdTF.placeholder = @"请输入密码";
    [self.passwordView addSubview:self.pwdTF];
    
    self.agreeResult = YES;
    __weak LMLoginViewController* weakSelf = self;
    
    self.agreementView = [[LMLoginAgreementView alloc]initWithFrame:CGRectMake(10, self.codeView.frame.origin.y + self.codeView.frame.size.height + spaceY, 190, 15)];
    self.agreementView.agreeBlock = ^(BOOL didAgree) {
        weakSelf.agreeResult = didAgree;
    };
    self.agreementView.clickBlock = ^(BOOL didClick) {
        LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
        [weakSelf.navigationController pushViewController:protocolVC animated:YES];
    };
    [self.scrollView addSubview:self.agreementView];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.agreementView.frame.origin.y + self.agreementView.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.sendBtn.backgroundColor = THEMEORANGECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    self.switchBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 150) / 2, self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + spaceY, 150, 20)];
    self.switchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
    [self.switchBtn setTitle:@"切换至密码登录" forState:UIControlStateNormal];
    [self.switchBtn setTitle:@"切换至验证码登录" forState:UIControlStateSelected];
    self.switchBtn.selected = NO;
    [self.switchBtn addTarget:self action:@selector(clickedSwitchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.switchBtn];
    
    UIButton* registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + spaceY, 80, 20)];
    NSMutableAttributedString* registerStr = [[NSMutableAttributedString alloc]initWithString:@"手机号注册" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [registerBtn setAttributedTitle:registerStr forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(clickedRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:registerBtn];
    
    UIButton* forgetPwdBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - spaceX - 60, registerBtn.frame.origin.y, 60, 20)];
    NSMutableAttributedString* forgetPwdStr = [[NSMutableAttributedString alloc]initWithString:@"忘记密码" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [forgetPwdBtn setAttributedTitle:forgetPwdStr forState:UIControlStateNormal];
    [forgetPwdBtn addTarget:self action:@selector(clickedForgetPwdButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:forgetPwdBtn];
    
    self.qqBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 100)];
    [self.qqBtn addTarget:self action:@selector(clickedQQButton:) forControlEvents:UIControlEventTouchUpInside];
    self.qqBtn.center = CGPointMake(self.view.frame.size.width * 2 / 3, self.view.frame.size.height - 150);
    [self.scrollView addSubview:self.qqBtn];
    
    UIImageView* qqIV = [[UIImageView alloc]initWithFrame:CGRectMake(13, 0, 53, 60)];
    qqIV.image = [UIImage imageNamed:@"fastLoginAlert_QQ_Color"];
    [self.qqBtn addSubview:qqIV];
    UILabel* qqLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 80, 20)];
    qqLab.font = [UIFont systemFontOfSize:16];
    qqLab.textColor = [UIColor grayColor];
    qqLab.text = @"QQ登录";
    qqLab.textAlignment = NSTextAlignmentCenter;
    [self.qqBtn addSubview:qqLab];
    
    BOOL installedWeChat = NO;//本地支持微信
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        installedWeChat = YES;
    }
    if ([LMTool getWeChatLoginOpen]) {
        if (installedWeChat) {
            [self createWeChatLoginButton];
        }
    }else {
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:26 ReqData:nil successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 26) {
                    BaiduSwitchRes* res = [BaiduSwitchRes parseFromData:apiRes.body];
                    BOOL openWeChat = NO;
                    if ([res hasIosWxqqOpen] && res.iosWxqqOpen) {
                        if (installedWeChat) {
                            openWeChat = YES;
                            
                            [self createWeChatLoginButton];
                        }
                    }
                    //
                    [LMTool saveWeChatLoginOpen:openWeChat];
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {
            
        }];
    }
    
    //微信 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatDidLogin:) name:weChatLoginNotifyName object:nil];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)createWeChatLoginButton {
    self.weChatBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, 80, 100)];
    [self.weChatBtn addTarget:self action:@selector(clickedWeChatButton:) forControlEvents:UIControlEventTouchUpInside];
    self.weChatBtn.center = CGPointMake(self.view.frame.size.width / 3, self.qqBtn.center.y);
    [self.scrollView addSubview:self.weChatBtn];
    
    UIImageView* weChatIV = [[UIImageView alloc]initWithFrame:CGRectMake(7, 0, 65, 60)];
    weChatIV.image = [UIImage imageNamed:@"fastLoginAlert_WeChat_Color"];
    [self.weChatBtn addSubview:weChatIV];
    UILabel* weChatLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 80, 20)];
    weChatLab.font = [UIFont systemFontOfSize:16];
    weChatLab.textColor = [UIColor grayColor];
    weChatLab.text = @"微信登录";
    weChatLab.textAlignment = NSTextAlignmentCenter;
    [self.weChatBtn addSubview:weChatLab];
}

-(void)clickedCodeButton:(UIButton* )sender {
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pattern = @"^1+[345678]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneStr];
    if (!isMatch) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    if (phoneStr.length > 11) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    if (phoneStr.length > 11) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    
    [self stopEditing];
    
    if (self.codeBtn.selected == NO) {
        VerifyCodeReqBuilder* builder = [VerifyCodeReq builder];
        [builder setPhoneNum:phoneStr];
        [builder setSmsType:SmsTypeSmsLogin];
        VerifyCodeReq* req = [builder build];
        NSData* reqData = [req data];
        
        [self showNetworkLoadingView];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:13 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 13) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        //初始化timer
                        [self setupTimer];
                        
                        self.codeBtn.selected = YES;
                        [self.timer setFireDate:[NSDate distantPast]];
                        
                    }else if (err == ErrCodeErrCountlimit) {//验证码次数超过上限
                        [self showMBProgressHUDWithText:@"验证码次数超过上限"];
                    }else if (err == ErrCodeErrTimelimit) {//验证码有效期内
                        
                    }else {
                        [self showMBProgressHUDWithText:@"获取验证码失败"];
                    }
                }
            } @catch (NSException *exception) {
                [self showMBProgressHUDWithText:@"获取验证码失败"];
            } @finally {
                
            }
            [self hideNetworkLoadingView];
        } failureBlock:^(NSError *failureError) {
            [self showMBProgressHUDWithText:@"获取验证码失败"];
            [self hideNetworkLoadingView];
        }];
    }
}

-(void)clickedSwitchButton:(UIButton* )sender {
    [self stopEditing];
    [self stopTimer];
    
    CGRect viewFrame = self.codeView.frame;
    CGRect codeFrame = CGRectZero;
    CGRect pwdFrame = CGRectZero;
    if (self.switchBtn.selected == YES) {
        self.switchBtn.selected = NO;
        codeFrame = CGRectMake(0, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
        pwdFrame = CGRectMake(viewFrame.size.width, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }else {
        self.switchBtn.selected = YES;
        codeFrame = CGRectMake(viewFrame.size.width, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
        pwdFrame = CGRectMake(0, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.codeView.frame = codeFrame;
        self.passwordView.frame = pwdFrame;
    }];
}

-(void)stopTimer {
    self.codeBtn.selected = NO;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    
    self.count = 60;
    
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

//收键盘
-(void)stopEditing {
    if ([self.phoneTF isFirstResponder]) {
        [self.phoneTF resignFirstResponder];
    }
    if ([self.codeTF isFirstResponder]) {
        [self.codeTF resignFirstResponder];
    }
    if ([self.pwdTF isFirstResponder]) {
        [self.pwdTF resignFirstResponder];
    }
}

//登录
-(void)clickedSendButton:(UIButton* )sender {
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    
    __weak LMLoginViewController* weakSelf = self;
    
    if (self.switchBtn.selected == YES) {//账号、密码登录
        NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (phoneStr.length == 0) {
            [self showMBProgressHUDWithText:@"手机号不能为空"];
            return;
        }
        NSString *pattern = @"^1+[345678]+\\d{9}";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL isMatch = [pred evaluateWithObject:phoneStr];
        if (!isMatch) {
            [self showMBProgressHUDWithText:@"手机格式不正确"];
            return;
        }
        if (pwdStr.length == 0) {
            [self showMBProgressHUDWithText:@"密码不能为空"];
            return;
        }
        if (phoneStr.length > 11) {
            [self showMBProgressHUDWithText:@"手机号码格式不正确"];
            return;
        }
        
        [self stopEditing];
        
        RegUserLoginReqBuilder* builder = [RegUserLoginReq builder];
        [builder setU:phoneStr];
        [builder setMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
        RegUserLoginReq* req = [builder build];
        NSData* reqData = [req data];
        
        [self showNetworkLoadingView];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:19 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 19) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        RegUserLoginRes* res = [RegUserLoginRes parseFromData:apiRes.body];
                        LoginedRegUser* logUser = res.loginedUser;
                        NSString* tokenStr = logUser.token;
                        if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                            
                            weakSelf.userBlock(logUser);
                            
                            //绑定设备与用户
                            [LMTool bindDeviceToUser:logUser];
                            
                            //保存登录用户信息
                            [LMTool saveLoginedRegUser:logUser];
                            
                            [weakSelf showMBProgressHUDWithText:@"登录成功"];
                            
                            //返回
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                                
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            });
                        }
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"账号或密码错误"];
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
    }else {//账号、验证码登录
        NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* codeStr = [self.codeTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (phoneStr.length == 0) {
            [self showMBProgressHUDWithText:@"手机号不能为空"];
            return;
        }
        NSString *pattern = @"^1+[345678]+\\d{9}";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL isMatch = [pred evaluateWithObject:phoneStr];
        if (!isMatch) {
            [self showMBProgressHUDWithText:@"手机格式不正确"];
            return;
        }
        if (codeStr.length == 0) {
            [self showMBProgressHUDWithText:@"验证码不能为空"];
            return;
        }
        if (phoneStr.length > 11) {
            [self showMBProgressHUDWithText:@"手机号码格式不正确"];
            return;
        }
        
        [self stopEditing];
        
        [self stopTimer];
        
        CheckVerifyCodeReqBuilder* builder = [CheckVerifyCodeReq builder];
        [builder setPhoneNum:phoneStr];
        [builder setVcode:codeStr];
        [builder setSmsType:SmsTypeSmsLogin];
        CheckVerifyCodeReq* req = [builder build];
        NSData* reqData = [req data];
        
        [self showNetworkLoadingView];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:14 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 14) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        
                        CheckVerifyCodeRes* res = [CheckVerifyCodeRes parseFromData:apiRes.body];
                        LoginedRegUser* logUser = res.loginedUser;
                        NSString* tokenStr = logUser.token;
                        if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                            
                            //绑定设备与用户
                            [LMTool bindDeviceToUser:logUser];
                            
                            //保存登录用户信息
                            [LMTool saveLoginedRegUser:logUser];
                            
                            [weakSelf showMBProgressHUDWithText:@"登录成功"];
                            
                            //返回
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                                
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            });
                        }
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"账号或密码错误"];
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                [weakSelf hideNetworkLoadingView];
            }
        } failureBlock:^(NSError *failureError) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            [weakSelf hideNetworkLoadingView];
        }];
    }
}

//注册
-(void)clickedRegisterButton:(UIButton* )sender {
    [self stopEditing];
    
    LMCheckVerifyCodeViewController* registerVC = [[LMCheckVerifyCodeViewController alloc]init];
    registerVC.type = SmsTypeSmsReg;
    [self.navigationController pushViewController:registerVC animated:YES];
}

//忘记密码
-(void)clickedForgetPwdButton:(UIButton* )sender {
    [self stopEditing];
    
    LMCheckVerifyCodeViewController* registerVC = [[LMCheckVerifyCodeViewController alloc]init];
    registerVC.type = SmsTypeSmsForgotpwd;
    [self.navigationController pushViewController:registerVC animated:YES];
}

//点击 微信 登录
-(void)clickedWeChatButton:(UIButton* )sender {
    [self stopEditing];
    
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        //
        SendAuthReq* request = [[SendAuthReq alloc]init];
        request.state = weChatLoginState;
        request.scope = @"snsapi_userinfo";
        [WXApi sendReq:request];
    }else {
        [self showMBProgressHUDWithText:@"打开微信失败"];
    }
}

//微信 登录成功
-(void)weChatDidLogin:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
        [self showMBProgressHUDWithText:@"登录失败"];
        return;
    }
    NSString* codeStr = [dic objectForKey:weChatLoginKey];
    if (codeStr != nil && ![codeStr isKindOfClass:[NSNull class]] && codeStr.length > 0) {
        RegUserBuilder* userBuilder = [RegUser builder];
        [userBuilder setWx:@"1"];
        RegUser* regUser = [userBuilder build];
        [self uploadThirdLoginWithUser:regUser codeStr:codeStr];
    }else {
        [self showMBProgressHUDWithText:@"登录失败"];
    }
}

//点击 QQ 登录
-(void)clickedQQButton:(UIButton* )sender {
    [self stopEditing];
    
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    
    //
    self.qqAuth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:self];
    NSArray* permissionArr = @[@"get_user_info", @"get_simple_userinfo"];
    [self.qqAuth authorize:permissionArr inSafari:NO];
}

#pragma mark -TencentSessionDelegate
-(void)tencentDidLogin {
    if (self.qqAuth.accessToken && [self.qqAuth.accessToken length] != 0) {
        RegUserBuilder* userBuilder = [RegUser builder];
        [userBuilder setQq:@"2"];
        RegUser* regUser = [userBuilder build];
        [self uploadThirdLoginWithUser:regUser codeStr:self.qqAuth.accessToken];
    }else {
        [self showMBProgressHUDWithText:@"登录失败"];
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled {
    [self showMBProgressHUDWithText:@"登录失败"];
}

-(void)tencentDidNotNetWork {
    [self showMBProgressHUDWithText:@"登录失败"];
}

-(void)getUserInfoResponse:(APIResponse *)response {
    
}

//third login
-(void)uploadThirdLoginWithUser:(RegUser* )user codeStr:(NSString* )codeStr {
    ThirdRegUserLoginReqBuilder* builder = [ThirdRegUserLoginReq builder];
    [builder setUser:user];
    [builder setCode:codeStr];
    ThirdRegUserLoginReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMLoginViewController* weakSelf = self;
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:34 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 34) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [weakSelf hideNetworkLoadingView];
                    
                    ThirdRegUserLoginRes* res = [ThirdRegUserLoginRes parseFromData:apiRes.body];
                    LoginedRegUser* logUser = res.loginedUser;
                    NSString* tokenStr = logUser.token;
                    if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                        
                        //block回调
                        if (weakSelf.userBlock) {
                            weakSelf.userBlock(logUser);
                        }
                        
                        //绑定设备与用户
                        [LMTool bindDeviceToUser:logUser];
                        
                        //保存登录用户信息
                        [LMTool saveLoginedRegUser:logUser];
                        
                        [weakSelf showMBProgressHUDWithText:@"登录成功"];
                        
                        //返回
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                            
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"出错啦^_^"];
                    }
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:@"出错啦^_^"];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:@"网络请求失败"];
        [weakSelf hideNetworkLoadingView];
    }];
}

//
-(void)setupTimer {
    if (!self.timer) {
        self.count = 60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCount) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

//
-(void)startCount {
    self.count --;
    if (self.count <= 0) {
        [self stopTimer];
        
        return;
    }
    [self.codeBtn setTitle:[NSString stringWithFormat:@"剩余%lds", self.count] forState:UIControlStateNormal];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatLoginNotifyName object:nil];
    
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
