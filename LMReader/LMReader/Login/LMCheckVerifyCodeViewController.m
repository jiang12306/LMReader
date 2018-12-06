//
//  LMCheckVerifyCodeViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMCheckVerifyCodeViewController.h"
#import "LMSetPasswordViewController.h"
#import "LMLoginAgreementView.h"
#import "LMProfileProtocolViewController.h"
#import "LMTool.h"

@interface LMCheckVerifyCodeViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* phoneTF;
@property (nonatomic, strong) UITextField* codeTF;
@property (nonatomic, strong) UIButton* codeBtn;
@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) LMLoginAgreementView* agreementView;/**<用户隐私协议*/
@property (nonatomic, assign) BOOL agreeResult;/**<用户是否同意*/

@end

@implementation LMCheckVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"获取验证码";
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    UIView* phoneView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.scrollView.frame.size.width, 50)];
    [self.scrollView addSubview:phoneView];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, phoneView.frame.size.width - 20 * 2, 30)];
    self.phoneTF.font = [UIFont systemFontOfSize:15];
    self.phoneTF.placeholder = @"请输入手机号";
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [phoneView addSubview:self.phoneTF];
    
    UIView* phoneLineView = [[UIView alloc]initWithFrame:CGRectMake(20, phoneView.frame.size.height - 1, phoneView.frame.size.width - 20 * 2, 1)];
    phoneLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    [phoneView addSubview:phoneLineView];
    
    UIView* codeView = [[UIView alloc]initWithFrame:CGRectMake(0, phoneView.frame.origin.y + phoneView.frame.size.height, self.view.frame.size.width, 50)];
    [self.scrollView addSubview:codeView];
    
    self.codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(codeView.frame.size.width - 20 - 80, 10, 80, 30)];
    self.codeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
    [self.codeBtn addTarget:self action:@selector(clickedCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    self.codeBtn.selected = NO;
    [codeView addSubview:self.codeBtn];
    
    UIView* verticalLineView = [[UIView alloc]initWithFrame:CGRectMake(self.codeBtn.frame.origin.x - 1 - 20, self.codeBtn.frame.origin.y, 1, self.codeBtn.frame.size.height)];
    verticalLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    [codeView addSubview:verticalLineView];
    
    self.codeTF = [[UITextField alloc]initWithFrame:CGRectMake(20, self.codeBtn.frame.origin.y, verticalLineView.frame.origin.x - 20 * 2, self.phoneTF.frame.size.height)];
    self.codeTF.font = [UIFont systemFontOfSize:15];
    self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.codeTF.placeholder = @"请输入验证码";
    [codeView addSubview:self.codeTF];
    
    UIView* codeLineView = [[UIView alloc]initWithFrame:CGRectMake(20, codeView.frame.size.height - 1, codeView.frame.size.width - 20 * 2, 1)];
    codeLineView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    [codeView addSubview:codeLineView];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, codeView.frame.origin.y + codeView.frame.size.height + 20, self.view.frame.size.width - 60 * 2, 45)];
    self.sendBtn.backgroundColor = THEMEORANGECOLOR;
    self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height / 2;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    if (self.type == SmsTypeSmsReg) {
        CGFloat naviHeight = 20 + 44;
        CGFloat bottomY = 20;
        if ([LMTool isBangsScreen]) {
            naviHeight = 44 + 44;
            bottomY = 30;
        }
        self.agreeResult = YES;
        __weak LMCheckVerifyCodeViewController* weakSelf = self;
        self.agreementView = [[LMLoginAgreementView alloc]initWithFrame:CGRectMake((self.scrollView.frame.size.width - 160) / 2,  self.scrollView.frame.size.height - naviHeight - bottomY - 15, 160, 15) agreeType:LMLoginAgreementViewTypeRegister];
        self.agreementView.agreeBlock = ^(BOOL didAgree) {
            weakSelf.agreeResult = didAgree;
        };
        self.agreementView.clickBlock = ^(BOOL didClick) {
            LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
            [weakSelf.navigationController pushViewController:protocolVC animated:YES];
        };
        [self.scrollView addSubview:self.agreementView];
    }
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

-(void)stopEditing {
    if ([self.phoneTF isFirstResponder]) {
        [self.phoneTF resignFirstResponder];
    }
    if ([self.codeTF isFirstResponder]) {
        [self.codeTF resignFirstResponder];
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
        [self.timer setFireDate:[NSDate distantFuture]];
        self.count = 60;
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.codeBtn.selected = NO;
        return;
    }
    [self.codeBtn setTitle:[NSString stringWithFormat:@"剩余%lds", self.count] forState:UIControlStateNormal];
}

//
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
        if (self.type == SmsTypeSmsReg) {
            [builder setSmsType:SmsTypeSmsReg];
        }else if (self.type == SmsTypeSmsForgotpwd) {
            [builder setSmsType:SmsTypeSmsForgotpwd];
        }else if (self.type == SmsTypeSmsBind) {
            [builder setSmsType:SmsTypeSmsBind];
        }
        VerifyCodeReq* req = [builder build];
        NSData* reqData = [req data];
        
        [self showNetworkLoadingView];
        __weak LMCheckVerifyCodeViewController* weakSelf = self;
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:13 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 13) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        //初始化timer
                        [weakSelf setupTimer];
                        
                        weakSelf.codeBtn.selected = YES;
                        [weakSelf.timer setFireDate:[NSDate distantPast]];
                        
                        [weakSelf showMBProgressHUDWithText:@"获取验证码成功"];
                        
                    }else if (err == ErrCodeErrCountlimit) {//验证码次数超过上限
                        [weakSelf showMBProgressHUDWithText:@"验证码次数超过上限"];
                    }else if (err == ErrCodeErrTimelimit) {//验证码有效期内
                        [weakSelf showMBProgressHUDWithText:@"验证码有效期内"];
                    }else if (err == ErrCodeErrPhonenumhavereg) {//手机号已被注册
                        [weakSelf showMBProgressHUDWithText:@"手机号已被占用"];
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"获取验证码失败"];
                    }
                }
                
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                
            }
            [weakSelf hideNetworkLoadingView];
        } failureBlock:^(NSError *failureError) {
            [weakSelf showMBProgressHUDWithText:@"获取验证码失败"];
            [weakSelf hideNetworkLoadingView];
        }];
    }
}

//注册/提交 按钮
-(void)clickedSendButton:(UIButton* )sender {
//    LMSetPasswordViewController* setPwdVC = [[LMSetPasswordViewController alloc]init];
//    setPwdVC.phoneStr = self.phoneTF.text;
//    setPwdVC.verifyStr = @"";
//    setPwdVC.type = self.type;
//    [self.navigationController pushViewController:setPwdVC animated:YES];
//    return;
    
    if (self.agreeResult == NO) {
        [self showMBProgressHUDWithText:@"尚未同意《用户隐私协议》"];
        return;
    }
    
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* verifyStr = self.codeTF.text;
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
    if (verifyStr.length == 0) {
        [self showMBProgressHUDWithText:@"验证码不能为空"];
        return;
    }
    if (phoneStr.length > 11) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    
    CheckVerifyCodeReqBuilder* builder = [CheckVerifyCodeReq builder];
    [builder setPhoneNum:phoneStr];
    [builder setVcode:verifyStr];
    if (self.type == SmsTypeSmsReg) {
        [builder setSmsType:SmsTypeSmsReg];
    }else if (self.type == SmsTypeSmsForgotpwd) {
        [builder setSmsType:SmsTypeSmsForgotpwd];
    }else if (self.type == SmsTypeSmsBind) {
        [builder setSmsType:SmsTypeSmsBind];
    }
    CheckVerifyCodeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMCheckVerifyCodeViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:14 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 14) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    if (weakSelf.bindPhone) {
                        if (weakSelf.bindBlock) {
                            weakSelf.bindBlock(phoneStr);
                            return;
                        }
                    }
                    LMSetPasswordViewController* setPwdVC = [[LMSetPasswordViewController alloc]init];
                    setPwdVC.phoneStr = weakSelf.phoneTF.text;
                    setPwdVC.verifyStr = verifyStr;
                    setPwdVC.type = weakSelf.type;
                    [weakSelf.navigationController pushViewController:setPwdVC animated:YES];
                    
                }else {
                    [weakSelf showMBProgressHUDWithText:@"验证码错误"];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:@"获取验证码失败"];
        [weakSelf hideNetworkLoadingView];
    }];
}

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
