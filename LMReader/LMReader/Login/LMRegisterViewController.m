//
//  LMRegisterViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRegisterViewController.h"
#import "LMSetPasswordViewController.h"

@interface LMRegisterViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* phoneTF;
@property (nonatomic, strong) UITextField* codeTF;
@property (nonatomic, strong) UIButton* codeBtn;
@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation LMRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    if (self.type == LMRegisterTypeNewRegister) {
        self.title = @"注册";
    }else {
        self.title = @"忘记密码";
    }
    
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
    
    UILabel* codeLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, phoneLab.frame.origin.y + phoneLab.frame.size.height + spaceY, 60, labHeight)];
    phoneLab.font = [UIFont systemFontOfSize:16];
    codeLab.text = @"验证码";
    [self.scrollView addSubview:codeLab];
    
    self.codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - spaceX - 80, codeLab.frame.origin.y, 80, labHeight)];
    self.codeBtn.layer.cornerRadius = 5;
    self.codeBtn.layer.masksToBounds = YES;
    self.codeBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.codeBtn.layer.borderWidth = 1;
    self.codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.codeBtn addTarget:self action:@selector(clickedCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    self.codeBtn.selected = NO;
    [self.scrollView addSubview:self.codeBtn];
    
    self.codeTF = [[UITextField alloc]initWithFrame:CGRectMake(self.phoneTF.frame.origin.x, codeLab.frame.origin.y, self.codeBtn.frame.origin.x - codeLab.frame.size.width - spaceX * 3, self.phoneTF.frame.size.height)];
    self.codeTF.backgroundColor = [UIColor whiteColor];
    self.codeTF.layer.cornerRadius = 5;
    self.codeTF.layer.masksToBounds = YES;
    self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.codeTF.secureTextEntry = YES;
    [self.scrollView addSubview:self.codeTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, codeLab.frame.origin.y + codeLab.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, 35)];
    self.sendBtn.backgroundColor = THEMECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    if (self.type == LMRegisterTypeNewRegister) {
        [self.sendBtn setTitle:@"注 册" forState:UIControlStateNormal];
    }else {
        [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    }
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    //初始化timer
//    [self setupTimer];
    
    /*
    UIButton* loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - spaceX - 60, registerBtn.frame.origin.y, 60, 20)];
    NSMutableAttributedString* forgetPwdStr = [[NSMutableAttributedString alloc]initWithString:@"登录" attributes:@{NSForegroundColorAttributeName : THEMECOLOR, NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [loginBtn setAttributedTitle:forgetPwdStr forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(clickedForgetPwdButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:loginBtn];
     */
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
    NSString *pattern = @"^1+[34578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneStr];
    if (!isMatch) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    
    if (self.codeBtn.selected == NO) {
        
        [self showNetworkLoadingView];
        
        VerifyCodeReqBuilder* builder = [VerifyCodeReq builder];
        [builder setPhoneNum:phoneStr];
        if (self.type == LMRegisterTypeNewRegister) {
            [builder setSmsType:SmsTypeSmsReg];
        }else {
            [builder setSmsType:SmsTypeSmsForgotpwd];
        }
        VerifyCodeReq* req = [builder build];
        NSData* reqData = [req data];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:13 ReqData:reqData successBlock:^(NSData *successData) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 13) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    //初始化timer
                    [self setupTimer];
                    
                    self.codeBtn.selected = YES;
                    [self.timer setFireDate:[NSDate distantPast]];
                    
                }else {
                    [self showMBProgressHUDWithText:@"获取验证码失败"];
                }
            }
            [self hideNetworkLoadingView];
        } failureBlock:^(NSError *failureError) {
            [self showMBProgressHUDWithText:@"获取验证码失败"];
            [self hideNetworkLoadingView];
        }];
    }
}

//注册/提交 按钮
-(void)clickedSendButton:(UIButton* )sender {
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* verifyStr = self.codeTF.text;
    if (phoneStr.length == 0) {
        [self showMBProgressHUDWithText:@"手机号不能为空"];
        return;
    }
    if (verifyStr.length == 0) {
        [self showMBProgressHUDWithText:@"验证码不能为空"];
        return;
    }
    [self showNetworkLoadingView];
    
    CheckVerifyCodeReqBuilder* builder = [CheckVerifyCodeReq builder];
    [builder setPhoneNum:phoneStr];
    [builder setVcode:verifyStr];
    if (self.type == LMRegisterTypeNewRegister) {
        [builder setSmsType:SmsTypeSmsReg];
    }else {
        [builder setSmsType:SmsTypeSmsForgotpwd];
    }
    CheckVerifyCodeReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:14 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 14) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                
                LMSetPasswordViewController* setPwdVC = [[LMSetPasswordViewController alloc]init];
                setPwdVC.phoneStr = self.phoneTF.text;
                setPwdVC.verifyStr = verifyStr;
                setPwdVC.type = self.type;
                [self.navigationController pushViewController:setPwdVC animated:YES];
                
            }else {
                [self showMBProgressHUDWithText:@"验证码错误"];
            }
        }
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [self showMBProgressHUDWithText:@"获取验证码失败"];
        [self hideNetworkLoadingView];
    }];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.timer) {
        self.codeBtn.selected = NO;
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
