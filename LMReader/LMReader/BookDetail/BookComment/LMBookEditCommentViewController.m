//
//  LMBookEditCommentViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookEditCommentViewController.h"
#import "LMCommentStarView.h"
#import "LMTool.h"
#import "LMLoginAlertView.h"
#import "LMProfileProtocolViewController.h"

@interface LMBookEditCommentViewController () <UITextViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) LMCommentStarView* starView;
@property (nonatomic, strong) UILabel* starLab;
@property (nonatomic, assign) NSInteger commentStarCount;
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UILabel* placeholderLab;
@property (nonatomic, strong) UILabel* alertLab;
@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, copy) NSDictionary* starDic;

@end

@implementation LMBookEditCommentViewController

static NSInteger textCount = 300;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"写评论";
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.scrollView.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.starDic = @{@0 : @"给个评分吧", @1 : @"浪费生命", @2 : @"打发时间", @3 : @"值得一看", @4 : @"非常喜欢", @5 : @"必看神作"};
    
    __weak LMBookEditCommentViewController* weakSelf = self;
    
    CGFloat starWidth = 25 * 5 + 10 * 4;
    self.starView = [[LMCommentStarView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - starWidth) / 2, 20, starWidth, 25)];
    self.starView.starBlock = ^(NSInteger starCount) {
        weakSelf.commentStarCount = starCount;
        NSNumber* numKey = [NSNumber numberWithInteger:starCount];
        weakSelf.starLab.text = [weakSelf.starDic objectForKey:numKey];
    };
    [self.scrollView addSubview:self.starView];
    
    self.starLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.starView.frame.origin.y + self.starView.frame.size.height + 10, self.view.frame.size.width, 20)];
    self.starLab.font = [UIFont systemFontOfSize:16];
    self.starLab.textAlignment = NSTextAlignmentCenter;
    self.starLab.text = [self.starDic objectForKey:@0];
    [self.scrollView addSubview:self.starLab];
    
    UIView* bgVi = [[UIView alloc]initWithFrame:CGRectMake(20, self.starLab.frame.origin.y + self.starLab.frame.size.height + 20, self.view.frame.size.width - 20 * 2, 140)];
    bgVi.backgroundColor = [UIColor whiteColor];
    bgVi.layer.cornerRadius = 3;
    bgVi.layer.masksToBounds = YES;
    [self.scrollView addSubview:bgVi];
    
    self.placeholderLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 7, bgVi.frame.size.width - 10, 20)];
    self.placeholderLab.font = [UIFont systemFontOfSize:16];
    self.placeholderLab.textColor = [UIColor grayColor];
    self.placeholderLab.text = @"请说说阅读感受吧，少于300个字";
    [bgVi addSubview:self.placeholderLab];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, bgVi.frame.size.width - 10, bgVi.frame.size.height - 10)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.delegate = self;
    [bgVi addSubview:self.textView];
    
    self.alertLab = [[UILabel alloc]initWithFrame:CGRectMake(0, bgVi.frame.origin.y + bgVi.frame.size.height + 10, self.scrollView.frame.size.width - 20, 15)];
    self.alertLab.font = [UIFont systemFontOfSize:12];
    self.alertLab.textColor = [UIColor grayColor];
    self.alertLab.textAlignment = NSTextAlignmentRight;
    self.alertLab.text = @"300/300字";
    [self.scrollView addSubview:self.alertLab];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, self.alertLab.frame.origin.y + self.alertLab.frame.size.height + 20, self.view.frame.size.width - 60 * 2, 45)];
    self.sendBtn.backgroundColor = THEMEORANGECOLOR;
    self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height / 2;
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    self.commentStarCount = 0;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //键盘 通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification* )notify {
    NSDictionary *userInfo = notify.userInfo;
    NSNumber* rectValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = rectValue.CGRectValue.size.height;
    NSNumber* animationNum = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat heightY = 0;
    if ([UIScreen mainScreen].bounds.size.height <= 568) {
        CGFloat tempY = self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + 30 - keyboardHeight;
        
        heightY = tempY > 0 ? tempY : 0;
    }
    
    [UIView animateWithDuration:animationNum.floatValue animations:^{
        self.scrollView.contentSize = CGSizeMake(0, self.view.frame.size.height + heightY);
        self.scrollView.contentOffset = CGPointMake(0, heightY);
    }];
}

-(void)keyboardWillHide:(NSNotification* )notify {
    self.scrollView.contentSize = CGSizeMake(0, self.view.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

//
-(void)tapped:(UITapGestureRecognizer* )tapGR {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark -UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholderLab.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString* text = self.textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length > 0) {
        self.placeholderLab.hidden = YES;
        return;
    }
    self.placeholderLab.hidden = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString* text = self.textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length > textCount) {
        self.textView.text = [text substringToIndex:textCount];
    }
    
    NSInteger surplusCount = textCount - text.length;
    if (surplusCount < 0) {
        surplusCount = 0;
    }
    self.alertLab.text = [NSString stringWithFormat:@"%ld/%ld字", surplusCount, textCount];
}

-(void)clickedSendButton:(UIButton* )sender {
    if (self.commentStarCount <= 0) {
        [self showMBProgressHUDWithText:@"请选择评分"];
        return;
    }
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        [self uploadStarDate];
    }else {
        __weak LMBookEditCommentViewController* weakSelf = self;
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                [weakSelf uploadStarDate];
            }
        };
        loginAV.protocolBlock = ^(BOOL clickedProtocol) {
            if (clickedProtocol) {
                LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
                [weakSelf.navigationController pushViewController:protocolVC animated:YES];
            }
        };
        [loginAV startShow];
        return;
    }
}

-(void)uploadStarDate {
    NSString* text = self.textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* commentText = [self.starDic objectForKey:[NSNumber numberWithInteger:self.commentStarCount]];
    if (text.length > 0) {
        commentText = text;
    }
    
    CommentBuilder* commentBuilder = [Comment builder];
    [commentBuilder setBookId:self.bookId];
    [commentBuilder setStarC:(UInt32 )self.commentStarCount];
    [commentBuilder setText:commentText];
    Comment* comment = [commentBuilder build];
    
    PubCommentReqBuilder* builder = [PubCommentReq builder];
    [builder setComment:comment];
    PubCommentReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookEditCommentViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:36 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            [weakSelf hideNetworkLoadingView];
            
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 36) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    if (weakSelf.commentBlock) {
                        [weakSelf.navigationController popViewControllerAnimated:NO];
                        weakSelf.commentBlock(YES);
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"操作成功"];
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshComment" object:nil userInfo:@{@"bookId" : [NSNumber numberWithUnsignedInt:self.bookId]}];
                        
                        dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    }
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
