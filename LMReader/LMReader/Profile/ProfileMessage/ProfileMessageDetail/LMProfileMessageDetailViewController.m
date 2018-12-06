//
//  LMProfileMessageDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMProfileMessageDetailViewController.h"

@interface LMProfileMessageDetailViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) SysMsg* detailMsg;

@end

@implementation LMProfileMessageDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息详情";
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    //
    [self loadMessageDetail];
}

-(void)setupDetailSubviews {
    if (self.detailMsg) {
        UILabel* titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.scrollView.frame.size.width - 20 * 2, 20)];
        titleLab.font = [UIFont boldSystemFontOfSize:18];
        titleLab.numberOfLines = 0;
        titleLab.lineBreakMode = NSLineBreakByCharWrapping;
        titleLab.text = self.detailMsg.title;
        CGSize titleSize = [titleLab sizeThatFits:CGSizeMake(self.scrollView.frame.size.width - 20 * 2, CGFLOAT_MAX)];
        titleLab.frame = CGRectMake(20, 20, self.scrollView.frame.size.width - 20 * 2, titleSize.height);
        [self.scrollView addSubview:titleLab];
        
        UILabel* timeLab = [[UILabel alloc]initWithFrame:CGRectMake(20, titleLab.frame.origin.y + titleLab.frame.size.height + 20, self.scrollView.frame.size.width - 20 * 2, 20)];
        timeLab.font = [UIFont systemFontOfSize:15];
        timeLab.text = self.detailMsg.sT;
        [self.scrollView addSubview:timeLab];
        
        UILabel* detailLab = [[UILabel alloc]initWithFrame:CGRectMake(20, titleLab.frame.origin.y + titleLab.frame.size.height + 20, timeLab.frame.size.width, 20)];
        detailLab.font = [UIFont systemFontOfSize:15];
        detailLab.numberOfLines = 0;
        detailLab.lineBreakMode = NSLineBreakByCharWrapping;
        detailLab.text = self.detailMsg.content;
        CGSize detailSize = [detailLab sizeThatFits:CGSizeMake(self.scrollView.frame.size.width - 20 * 2, CGFLOAT_MAX)];
        detailLab.frame = CGRectMake(20, timeLab.frame.origin.y + timeLab.frame.size.height + 20, timeLab.frame.size.width, detailSize.height);
        [self.scrollView addSubview:detailLab];
        
        self.scrollView.contentSize = CGSizeMake(0, detailLab.frame.origin.y + detailLab.frame.size.height + 20);
    }
}

//
-(void)loadMessageDetail {
    [self showNetworkLoadingView];
    
    SysMsgReqBuilder* builder = [SysMsgReq builder];
    [builder setId:self.msgId];
    SysMsgReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMProfileMessageDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:47 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 47) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SysMsgRes* res = [SysMsgRes parseFromData:apiRes.body];
                    weakSelf.detailMsg = res.sysmsg;
                    
                    [weakSelf setupDetailSubviews];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    for (UIView* subVi in self.scrollView.subviews) {
        [subVi removeFromSuperview];
    }
    [self loadMessageDetail];
}

@end
