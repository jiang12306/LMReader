//
//  LMSearchHelpBookAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/23.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMSearchHelpBookAlertView.h"
#import "MBProgressHUD.h"
#import "LMNetworkTool.h"
#import "AppDelegate.h"

@interface LMSearchHelpBookAlertView ()

@property (nonatomic, strong) LMBaseAlertView* contentView;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UITextField* nameTF;
@property (nonatomic, strong) UITextField* authorTF;
@property (nonatomic, strong) UITextField* webTF;
@property (nonatomic, strong) UIButton* cancelBtn;
@property (nonatomic, strong) UIButton* sureBtn;

@property (nonatomic, strong) UILabel* successLab;

//网络加载视图
@property (nonatomic, strong) UIView* loadingView;
@property (nonatomic, strong) UIImageView* loadingIV;
@property (nonatomic, strong) UILabel* loadingLab;

@end

@implementation LMSearchHelpBookAlertView

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.18];
        self.contentView = [[LMBaseAlertView alloc]initWithFrame:CGRectMake((screenRect.size.width - frame.size.width) / 2, (screenRect.size.height - frame.size.height) / 2, frame.size.width, frame.size.height)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.contentView.frame.size.width, 20)];
        self.titleLab.font = [UIFont boldSystemFontOfSize:18];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.text = @"填写小说信息";
        [self.contentView addSubview:self.titleLab];
        
        NSString* nameStr = @"小说名称*";
        NSMutableAttributedString* nameAttributedStr = [[NSMutableAttributedString alloc]initWithString:nameStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor colorWithRed:120.f/255 green:120.f/255 blue:120.f/255 alpha:1]}];
        [nameAttributedStr addAttribute:NSForegroundColorAttributeName value:THEMEORANGECOLOR range:NSMakeRange(nameStr.length - 1, 1)];
        UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(20, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 20, 70, 30)];
        nameLab.attributedText = nameAttributedStr;
        [self.contentView addSubview:nameLab];
        self.nameTF = [[UITextField alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x + nameLab.frame.size.width + 10, nameLab.frame.origin.y, frame.size.width - nameLab.frame.origin.x - nameLab.frame.size.width - 20 * 2, nameLab.frame.size.height)];
        self.nameTF.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
        self.nameTF.layer.cornerRadius = 5;
        self.nameTF.layer.masksToBounds = YES;
        self.nameTF.font = [UIFont systemFontOfSize:15];
        self.nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:self.nameTF];
        
        UILabel* authorLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height + 20, nameLab.frame.size.width, nameLab.frame.size.height)];
        authorLab.font = [UIFont systemFontOfSize:15];
        authorLab.textColor = [UIColor colorWithRed:120.f/255 green:120.f/255 blue:120.f/255 alpha:1];
        authorLab.text = @"作者";
        [self.contentView addSubview:authorLab];
        self.authorTF = [[UITextField alloc]initWithFrame:CGRectMake(self.nameTF.frame.origin.x, authorLab.frame.origin.y, self.nameTF.frame.size.width, self.nameTF.frame.size.height)];
        self.authorTF.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
        self.authorTF.layer.cornerRadius = 5;
        self.authorTF.layer.masksToBounds = YES;
        self.authorTF.font = [UIFont systemFontOfSize:15];
        self.authorTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:self.authorTF];
        
        UILabel* webLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, authorLab.frame.origin.y + authorLab.frame.size.height + 20, nameLab.frame.size.width, nameLab.frame.size.height)];
        webLab.font = [UIFont systemFontOfSize:15];
        webLab.textColor = [UIColor colorWithRed:120.f/255 green:120.f/255 blue:120.f/255 alpha:1];
        webLab.text = @"在哪看过";
        [self.contentView addSubview:webLab];
        self.webTF = [[UITextField alloc]initWithFrame:CGRectMake(self.nameTF.frame.origin.x, webLab.frame.origin.y, self.nameTF.frame.size.width, self.nameTF.frame.size.height)];
        self.webTF.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
        self.webTF.layer.cornerRadius = 5;
        self.webTF.layer.masksToBounds = YES;
        self.webTF.placeholder = @"  网站或app名称";
        self.webTF.font = [UIFont systemFontOfSize:15];
        self.webTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:self.webTF];
        
        CGFloat spaceX = (frame.size.width - 60 * 2) / 4;
        self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.webTF.frame.origin.y + self.webTF.frame.size.height + 20, 60, 20)];
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelBtn];
        
        self.sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.cancelBtn.frame.origin.x + self.cancelBtn.frame.size.width + spaceX * 2, self.cancelBtn.frame.origin.y, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
        self.sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.sureBtn setTitle:@"提交" forState:UIControlStateNormal];
        [self.sureBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.sureBtn addTarget:self action:@selector(clickedSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.sureBtn];
        
        UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(self.cancelBtn.frame.origin.x + self.cancelBtn.frame.size.width + spaceX, self.cancelBtn.frame.origin.y, 1, 20)];
        lineView.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1];
        [self.contentView addSubview:lineView];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        tap.cancelsTouchesInView = NO;
        [self.contentView addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

//取消
-(void)clickedCancelButton:(UIButton* )sender {
    [self stopEditing];
    [self startHide];
}

//提交
-(void)clickedSureButton:(UIButton* )sender {
    [self stopEditing];
    
    NSString* nameStr = [self.nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (nameStr == nil || nameStr.length == 0) {
        [self showMBProgressHUDWithText:@"小说名不能为空"];
        return;
    }
    if (self.sureBtn.selected) {
        return;
    }
    NSString* authorStr = [self.authorTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* webStr = [self.webTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.sureBtn.selected = YES;
    
    SearchHelpReqBuilder* builder = [SearchHelpReq builder];
    [builder setBookName:nameStr];
    if (authorStr == nil || authorStr.length == 0) {
        [builder setBookAuthor:authorStr];
    }
    if (webStr == nil || webStr.length == 0) {
        [builder setWebStr:webStr];
    }
    SearchHelpReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:45 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 45) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    if (self.commitBlock) {
                        self.commitBlock(YES);
                    }
                    
                    self.successLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.contentView.frame.size.width - 20 * 2, self.contentView.frame.size.height - 20 * 2)];
                    self.successLab.backgroundColor = [UIColor whiteColor];
                    self.successLab.font = [UIFont systemFontOfSize:15];
                    self.successLab.numberOfLines = 0;
                    self.successLab.lineBreakMode = NSLineBreakByCharWrapping;
                    self.successLab.textAlignment = NSTextAlignmentLeft;
                    self.successLab.text = @"已收到您的反馈，给小管家1个工作日帮您找书，找到的书，会给您加到书架哦";
                    [self.contentView addSubview:self.successLab];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2), dispatch_get_main_queue(), ^{
                        [self startHide];
                    });
                }
            }
        } @catch (NSException *exception) {
            [self showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            self.sureBtn.selected = NO;

            [self hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        self.sureBtn.selected = NO;
        [self showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [self hideNetworkLoadingView];
    }];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

-(void)keyboardWillShow:(NSNotification* )notify {
    NSDictionary*info=[notify userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat btnPositionY = self.sureBtn.frame.origin.y + self.sureBtn.frame.size.height + 20;
    CGRect contentRect = self.contentView.frame;
    contentRect.origin.y = screenSize.height - keyboardHeight - btnPositionY;//(screenSize.height - keyboardHeight - contentRect.size.height) / 2;
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = contentRect;
    }];
}

-(void)keyboardWillHide:(NSNotification* )notify {
    NSDictionary*info=[notify userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect contentRect = self.contentView.frame;
    contentRect.origin.y = (screenSize.height - contentRect.size.height) / 2;
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = contentRect;
    }];
}

//显示
-(void)startShow {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect contentRect = self.contentView.frame;
    contentRect.size.height = self.sureBtn.frame.origin.y + self.sureBtn.frame.size.height + 20;
    contentRect.origin.y = (screenSize.height - contentRect.size.height) / 2;
    self.alpha = 0;
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.f;
        self.contentView.frame = contentRect;
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

//隐藏
- (void)startHide {
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.contentView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate sendSystemNightShiftToback];
}

//收键盘
-(void)stopEditing {
    if ([self.nameTF isFirstResponder]) {
        [self.nameTF resignFirstResponder];
    }
    if ([self.authorTF isFirstResponder]) {
        [self.authorTF resignFirstResponder];
    }
    if ([self.webTF isFirstResponder]) {
        [self.webTF resignFirstResponder];
    }
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
        
        [self.contentView addSubview:self.loadingView];
        self.loadingView.hidden = YES;
    }
    self.loadingView.center = CGPointMake(self.contentView.frame.size.width / 2, self.contentView.frame.size.height / 2);
    self.loadingView.hidden = NO;
    [self.loadingIV startAnimating];
    [self.contentView bringSubviewToFront:self.loadingView];
}

//隐藏 网络加载
-(void)hideNetworkLoadingView {
    [self.loadingIV stopAnimating];
    self.loadingView.hidden = YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    bool isContain = CGRectContainsPoint(self.contentView.frame, point);
    if (!isContain) {
        [self startHide];
    }
}

@end
