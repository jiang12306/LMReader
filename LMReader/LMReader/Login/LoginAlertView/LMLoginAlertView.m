//
//  LMLoginAlertView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/8/1.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMLoginAlertView.h"
#import "LMTool.h"
#import "LMNetworkTool.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MBProgressHUD.h"
#import "LMLoginAgreementView.h"
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"

@interface LMLoginAlertView () <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth* qqAuth;

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UIButton* closeBtn;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UITextField* phoneTF;

@property (nonatomic, strong) UIView* codeView;/**<验证码 视图*/
@property (nonatomic, strong) UITextField* codeTF;
@property (nonatomic, strong) UIButton* codeBtn;

@property (nonatomic, strong) UIView* passwordView;/**<密码 视图*/
@property (nonatomic, strong) UITextField* pwdTF;

@property (nonatomic, strong) LMLoginAgreementView* agreementView;/**<用户隐私协议*/
@property (nonatomic, assign) BOOL agreeResult;/**<用户是否同意*/

@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, strong) UIButton* switchBtn;/**<切换至密码登录*/

@property (nonatomic, strong) UIButton* weChatBtn;
@property (nonatomic, strong) UIButton* qqBtn;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) NSTimer* timer;

//网络加载视图
@property (nonatomic, strong) UIView* loadingView;
@property (nonatomic, strong) UIImageView* loadingIV;
@property (nonatomic, strong) UILabel* loadingLab;

@end

@implementation LMLoginAlertView

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, 0)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentView];
        
        self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 20, 20)];
        [self.closeBtn setImage:[UIImage imageNamed:@"ad_Close"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.closeBtn];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, screenRect.size.width - 120, 20)];
        self.titleLab.font = [UIFont systemFontOfSize:15];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.text = @"需登录才能操作";
        [self.contentView addSubview:self.titleLab];
        
        CGFloat spaceY = 20;
        
        UIView* phoneView = [[UIView alloc]initWithFrame:CGRectMake(0, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 20, self.contentView.frame.size.width, 50)];
        [self.contentView addSubview:phoneView];
        
        UIImageView* phoneIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 15, 20, 20)];
        phoneIV.image = [UIImage imageNamed:@"register_Avator"];
        [phoneView addSubview:phoneIV];
        
        self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(phoneIV.frame.origin.x + phoneIV.frame.size.width + 20, 10, phoneView.frame.size.width - phoneIV.frame.origin.x - phoneIV.frame.size.width - 20 * 2, 30)];
        self.phoneTF.font = [UIFont systemFontOfSize:15];
        self.phoneTF.placeholder = @"请输入手机号码";
        self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [phoneView addSubview:self.phoneTF];
        
        UIView* phoneLineView = [[UIView alloc]initWithFrame:CGRectMake(20, phoneView.frame.size.height - 1, phoneView.frame.size.width - 20 * 2, 1)];
        phoneLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        [phoneView addSubview:phoneLineView];
        
        self.codeView = [[UIView alloc]initWithFrame:CGRectMake(0, phoneView.frame.origin.y + phoneView.frame.size.height, self.contentView.frame.size.width, 50)];
        [self.contentView addSubview:self.codeView];
        
        self.codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.codeView.frame.size.width - 20 - 80, 10, 80, 30)];
        self.codeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.codeBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.codeBtn addTarget:self action:@selector(clickedCodeButton:) forControlEvents:UIControlEventTouchUpInside];
        self.codeBtn.selected = NO;
        [self.codeView addSubview:self.codeBtn];
        
        UIView* verticalLineView = [[UIView alloc]initWithFrame:CGRectMake(self.codeBtn.frame.origin.x - 1 - 20, self.codeBtn.frame.origin.y, 1, self.codeBtn.frame.size.height)];
        verticalLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        [self.codeView addSubview:verticalLineView];
        
        self.codeTF = [[UITextField alloc]initWithFrame:CGRectMake(20, self.codeBtn.frame.origin.y, verticalLineView.frame.origin.x - 20 * 2, self.phoneTF.frame.size.height)];
        self.codeTF.font = [UIFont systemFontOfSize:15];
        self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
        self.codeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.codeTF.placeholder = @"请输入验证码";
        [self.codeView addSubview:self.codeTF];
        
        UIView* codeLineView = [[UIView alloc]initWithFrame:CGRectMake(20, self.codeView.frame.size.height - 1, self.codeView.frame.size.width - 20 * 2, 1)];
        codeLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        [self.codeView addSubview:codeLineView];
        
        self.passwordView = [[UIView alloc]initWithFrame:CGRectMake(screenRect.size.width, self.codeView.frame.origin.y, screenRect.size.width, 50)];
        [self.contentView addSubview:self.passwordView];
        
        UIImageView* pwdIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 15, 20, 20)];
        pwdIV.image = [UIImage imageNamed:@"register_Password"];
        [self.passwordView addSubview:pwdIV];
        
        self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(pwdIV.frame.origin.x + pwdIV.frame.size.width + 20, 10, self.phoneTF.frame.size.width, self.phoneTF.frame.size.height)];
        self.pwdTF.font = [UIFont systemFontOfSize:15];
        self.pwdTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.pwdTF.secureTextEntry = YES;
        self.pwdTF.placeholder = @"请输入密码";
        [self.passwordView addSubview:self.pwdTF];
        
        UIView* pwdLineView = [[UIView alloc]initWithFrame:CGRectMake(20, self.passwordView.frame.size.height - 1, self.passwordView.frame.size.width - 20 * 2, 1)];
        pwdLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        [self.passwordView addSubview:pwdLineView];
        
        self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, self.codeView.frame.origin.y + self.codeView.frame.size.height + 20, screenRect.size.width - 60 * 2, 45)];
        self.sendBtn.backgroundColor = THEMEORANGECOLOR;
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height / 2;
        self.sendBtn.layer.masksToBounds = YES;
        [self.sendBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.sendBtn];
        
        self.switchBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenRect.size.width - 150) / 2, self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + spaceY, 150, 20)];
        self.switchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.switchBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.switchBtn setTitle:@"切换至密码登录" forState:UIControlStateNormal];
        [self.switchBtn setTitle:@"切换至验证码登录" forState:UIControlStateSelected];
        self.switchBtn.selected = NO;
        [self.switchBtn addTarget:self action:@selector(clickedSwitchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.switchBtn];
        
        self.qqBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.qqBtn addTarget:self action:@selector(clickedQQButton:) forControlEvents:UIControlEventTouchUpInside];
        self.qqBtn.center = CGPointMake(screenRect.size.width * 2 / 3, self.switchBtn.frame.origin.y + self.switchBtn.frame.size.height + spaceY + 50);
        [self.contentView addSubview:self.qqBtn];
        
        UIImageView* qqIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        qqIV.image = [UIImage imageNamed:@"qq_Gray"];
        [self.qqBtn addSubview:qqIV];
        
        self.agreeResult = YES;
        __weak LMLoginAlertView* weakSelf = self;
        self.agreementView = [[LMLoginAgreementView alloc]initWithFrame:CGRectMake((self.contentView.frame.size.width - 160) / 2, self.qqBtn.frame.origin.y + self.qqBtn.frame.size.height + spaceY, 160, 15) agreeType:LMLoginAgreementViewTypeLogin];
        self.agreementView.agreeBlock = ^(BOOL didAgree) {
            weakSelf.agreeResult = didAgree;
        };
        self.agreementView.clickBlock = ^(BOOL didClick) {
            if (weakSelf.protocolBlock) {
                weakSelf.protocolBlock(YES);
            }
            [weakSelf startHide];
        };
        [self.contentView addSubview:self.agreementView];
        
        BOOL installedWeChat = NO;//本地支持微信
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            installedWeChat = YES;
        }
        if ([LMTool getWeChatLoginOpen]) {
            if (installedWeChat) {
                [self createWeChatButton];
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
                                
                                [self createWeChatButton];
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
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        tap.cancelsTouchesInView = NO;
        [self.contentView addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        //微信 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatDidLogin:) name:weChatLoginNotifyName object:nil];
    }
    return self;
}

-(void)createWeChatButton {
    self.weChatBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.weChatBtn addTarget:self action:@selector(clickedWeChatButton:) forControlEvents:UIControlEventTouchUpInside];
    self.weChatBtn.center = CGPointMake(self.qqBtn.center.x / 2, self.qqBtn.center.y);
    [self.contentView addSubview:self.weChatBtn];
    
    UIImageView* weChatIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    weChatIV.image = [UIImage imageNamed:@"weChat_Gray"];
    [self.weChatBtn addSubview:weChatIV];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

-(void)keyboardWillShow:(NSNotification* )notify {
    NSDictionary*info=[notify userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    CGFloat btnPositionY = self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + 20;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = CGRectMake(0, screenSize.height - keyboardHeight - btnPositionY, screenSize.width, screenSize.height);
    }];
}

-(void)keyboardWillHide:(NSNotification* )notify {
    NSDictionary*info=[notify userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat contentHeight = self.agreementView.frame.origin.y + self.agreementView.frame.size.height + 20;
    if ([LMTool isBangsScreen]) {
        contentHeight += 20;
    }
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = CGRectMake(0, screenSize.height - contentHeight, screenSize.width, screenSize.height);
    }];
}

-(void)clickedCloseButton:(UIButton* )sender {
    [self startHide];
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

-(void)clickedSendButton:(UIButton* )sender {
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    __weak LMLoginAlertView* weakSelf = self;
    
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
                            
                            //绑定设备与用户
                            [LMTool bindDeviceToUser:logUser];
                            
                            //保存登录用户信息
                            [LMTool saveLoginedRegUser:logUser];
                            
                            if (weakSelf.loginBlock) {
                                weakSelf.loginBlock(YES);
                            }
                            
                            //返回
                            [weakSelf showMBProgressHUDWithText:@"登录成功"];
                            
                            [weakSelf startHide];
                            
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
                            
                            if (weakSelf.loginBlock) {
                                weakSelf.loginBlock(YES);
                            }
                            
                            //返回
                            [weakSelf showMBProgressHUDWithText:@"登录成功"];
                            
                            [weakSelf startHide];
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
        codeFrame = CGRectMake(0 - viewFrame.size.width, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
        pwdFrame = CGRectMake(0, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.codeView.frame = codeFrame;
        self.passwordView.frame = pwdFrame;
    }];
}

-(void)clickedWeChatButton:(UIButton* )sender {
    [self stopEditing];
    
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    
    [self stopTimer];
    
    //
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendAuthReq* request = [[SendAuthReq alloc]init];
        request.state = weChatLoginState;
        request.scope = @"snsapi_userinfo";
        [WXApi sendReq:request];
    }else {
        [self showMBProgressHUDWithText:@"打开微信失败"];
    }
}

-(void)clickedQQButton:(UIButton* )sender {
    [self stopEditing];
    
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    
    [self stopTimer];
    
    //
    self.qqAuth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:self];
    NSArray* permissionArr = @[@"get_user_info", @"get_simple_userinfo"];
    [self.qqAuth authorize:permissionArr inSafari:NO];
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

-(void)stopTimer {
    self.codeBtn.selected = NO;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    
    self.count = 60;
    
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.anyObject;
    UIView* touchView = touch.view;
    if (touchView != self.contentView) {
        [self startHide];
    }
}

-(void)startShow {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat contentHeight = self.agreementView.frame.origin.y + self.agreementView.frame.size.height + 20;
    if ([LMTool isBangsScreen]) {
        contentHeight += 20;
    }
    CGRect finalFrame = CGRectMake(0, screenSize.height - contentHeight, screenSize.width, screenSize.height);
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = finalFrame;
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

-(void)startHide {
    [self stopTimer];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect contentFrame = self.contentView.frame;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(0, screenSize.height, screenSize.width, contentFrame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate sendSystemNightShiftToback];
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
    
    __weak LMLoginAlertView* weakSelf = self;
    
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
                        
                        //绑定设备与用户
                        [LMTool bindDeviceToUser:logUser];
                        
                        //保存登录用户信息
                        [LMTool saveLoginedRegUser:logUser];
                        
                        if (weakSelf.loginBlock) {
                            weakSelf.loginBlock(YES);
                        }
                        
                        //返回
                        [weakSelf showMBProgressHUDWithText:@"登录成功"];
                        
                        [weakSelf startHide];
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
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf hideNetworkLoadingView];
    }];
}

-(void)showMBProgressHUDWithText:(NSString* )hudText {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hudText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
}

//显示 网络加载
-(void)showNetworkLoadingView {
    CGSize contentSize = [UIScreen mainScreen].bounds.size;
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake((contentSize.width - 70)/2, (contentSize.height - 70)/2, 70, 70)];
        self.loadingView.backgroundColor = [UIColor colorWithRed:80.f/255 green:80.f/255 blue:80.f/255 alpha:0.5];
        self.loadingView.layer.cornerRadius = 5;
        self.loadingView.layer.masksToBounds = YES;
        
        self.loadingIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 30)];
        NSMutableArray* imgArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 25; i ++) {
            NSString* imgStr = [NSString stringWithFormat:@"loading%ld", (long)i];
            UIImage* img = [UIImage imageNamed:imgStr];
            [imgArr addObject:img];
        }
        self.loadingIV.animationImages = imgArr;
        self.loadingIV.animationDuration = 1.5;
        [self.loadingView addSubview:self.loadingIV];
        
        self.loadingLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.loadingView.frame.size.height - 25, self.loadingView.frame.size.height, 20)];
        self.loadingLab.textColor = [UIColor whiteColor];
        self.loadingLab.textAlignment = NSTextAlignmentCenter;
        self.loadingLab.font = [UIFont systemFontOfSize:14];
        self.loadingLab.text = @"加载中";
        [self.loadingView addSubview:self.loadingLab];
        
        [self insertSubview:self.loadingView aboveSubview:self.contentView];
        self.loadingView.hidden = YES;
    }
    self.loadingView.center = CGPointMake(self.contentView.frame.size.width / 2, (self.frame.size.height + self.contentView.frame.origin.y) / 2);
    self.loadingView.hidden = NO;
    [self.loadingIV startAnimating];
    [self bringSubviewToFront:self.loadingView];
}

//隐藏 网络加载
-(void)hideNetworkLoadingView {
    [self.loadingIV stopAnimating];
    self.loadingView.hidden = YES;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatLoginNotifyName object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
