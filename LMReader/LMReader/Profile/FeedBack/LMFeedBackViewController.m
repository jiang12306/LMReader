//
//  LMFeedBackViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFeedBackViewController.h"
#import "LMComboxView.h"

typedef enum {
    LMFeedBackTypeExperience = 0,//体验问题
    LMFeedBackTypeCopyright = 1,//版权问题
}LMFeedBackType;

@interface LMFeedBackViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, assign) LMFeedBackType type;
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UITextField* phoneTF;
@property (nonatomic, strong) UITextField* emailTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"意见反馈";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 15;
    CGFloat labHeight = 30;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:241/255.f alpha:1];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.type = LMFeedBackTypeExperience;
    
    UILabel* typeLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, spaceY, 120, labHeight)];
    NSMutableAttributedString* typeStr = [[NSMutableAttributedString alloc]initWithString:@"选择问题类型*" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [typeStr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(typeStr.length - 1, 1)];
    [typeLab setAttributedText:typeStr];
    [self.scrollView addSubview:typeLab];
    
    __weak LMFeedBackViewController* weakSelf = self;
    
    NSArray* arr = @[@"APP体验问题", @"小说版权问题"];
    LMComboxView* comboxView = [[LMComboxView alloc]initWithFrame:CGRectMake(typeLab.frame.origin.x + typeLab.frame.size.width + spaceX, typeLab.frame.origin.y, self.view.frame.size.width - typeLab.frame.size.width - spaceX * 3, labHeight * (arr.count + 1)) titleArr:arr cellHeight:labHeight];
    [comboxView didSelectedIndex:^(NSInteger selectedIndex) {
        if (selectedIndex == 0) {
            weakSelf.type = LMFeedBackTypeExperience;
        }else if (selectedIndex == 1) {
            weakSelf.type = LMFeedBackTypeCopyright;
        }
    }];
    [self.scrollView addSubview:comboxView];
    
    UILabel* explainLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, labHeight * 3 + spaceY, 100, labHeight)];
    NSMutableAttributedString* explainStr = [[NSMutableAttributedString alloc]initWithString:@"问题描述*" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [explainStr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(explainStr.length - 1, 1)];
    [explainLab setAttributedText:explainStr];
    [self.scrollView addSubview:explainLab];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(spaceX, explainLab.frame.origin.y + explainLab.frame.size.height + 5, self.view.frame.size.width - 20, 100)];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.cornerRadius = 3;
    self.textView.layer.masksToBounds = YES;
    [self.scrollView addSubview:self.textView];
    
    UILabel* phoneLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, self.textView.frame.origin.y + self.textView.frame.size.height + spaceY, 60, labHeight)];
    NSMutableAttributedString* phoneStr = [[NSMutableAttributedString alloc]initWithString:@"手机号*" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [phoneStr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(phoneStr.length - 1, 1)];
    [phoneLab setAttributedText:phoneStr];
    [self.scrollView addSubview:phoneLab];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(phoneLab.frame.origin.x + phoneLab.frame.size.width + spaceX, phoneLab.frame.origin.y, self.view.frame.size.width - phoneLab.frame.size.width - spaceX * 3, labHeight)];
    self.phoneTF.backgroundColor = [UIColor whiteColor];
    self.phoneTF.layer.cornerRadius = 5;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.scrollView addSubview:self.phoneTF];
    
    UILabel* emailLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, phoneLab.frame.origin.y + phoneLab.frame.size.height + spaceY, 60, labHeight)];
    emailLab.font = [UIFont systemFontOfSize:16];
    emailLab.text = @"邮箱";
    [self.scrollView addSubview:emailLab];
    
    self.emailTF = [[UITextField alloc]initWithFrame:CGRectMake(self.phoneTF.frame.origin.x, emailLab.frame.origin.y, self.phoneTF.frame.size.width, self.phoneTF.frame.size.height)];
    self.emailTF.backgroundColor = [UIColor whiteColor];
    self.emailTF.layer.cornerRadius = 5;
    self.emailTF.layer.masksToBounds = YES;
    self.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.scrollView addSubview:self.emailTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, emailLab.frame.origin.y + emailLab.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, 35)];
    self.sendBtn.backgroundColor = THEMECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
}

-(void)clickedSendButton:(UIButton* )sender {
    NSString* wordsStr = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* emailStr = [self.emailTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pattern = @"^1+[34578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneStr];
    if (wordsStr.length == 0) {
        [self showMBProgressHUDWithText:@"问题描述不能为空"];
        return;
    }
    if (!isMatch) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    
    [self showNetworkLoadingView];
    
    UInt32 typeInt = 0;
    if (self.type == LMFeedBackTypeCopyright) {
        typeInt = 1;
    }
    FeedbackReqBuilder* builder = [FeedbackReq builder];
    [builder setType:typeInt];
    [builder setWords:wordsStr];
    [builder setPhoneNum:phoneStr];
    [builder setEmail:emailStr];
    FeedbackReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:16 ReqData:reqData successBlock:^(NSData *successData) {
        
        [self hideNetworkLoadingView];
        
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 16) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
                [self showMBProgressHUDWithText:@"感谢您的反馈，我们将尽快处理"];
            }
        }
        
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
