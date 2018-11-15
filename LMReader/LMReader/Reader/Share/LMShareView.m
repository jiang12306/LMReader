//
//  LMShareView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/5.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMShareView.h"
#import "LMTool.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "AppDelegate.h"

@interface LMShareView ()

@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIButton* cancelBtn;
@property (nonatomic, assign) BOOL hasWeChat;
@property (nonatomic, assign) BOOL hasQQ;

@end

@implementation LMShareView

CGFloat shareBtnWidth = 60;

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self];
        self.hidden = YES;
        
        CGFloat totalHeight = 80 + shareBtnWidth + 10 + 20 + 30 + 50;
        if ([LMTool isBangsScreen]) {
            totalHeight += 44;
        }
        
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height - totalHeight, screenRect.size.width, totalHeight)];
        self.bgView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        [self addSubview:self.bgView];
        
        UILabel* titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width, 80)];
        titleLab.font = [UIFont systemFontOfSize:18];
        titleLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = @"分享至";
        [self.bgView addSubview:titleLab];
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, titleLab.frame.origin.y + titleLab.frame.size.height, self.frame.size.width, shareBtnWidth + 10 + 20)];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self.bgView addSubview:self.scrollView];
        
        self.hasWeChat = NO;
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            self.hasWeChat = YES;
        }
        self.hasQQ = NO;
        if ([TencentOAuth iphoneQQInstalled] || [TencentOAuth iphoneTIMInstalled]) {
            self.hasQQ = YES;
        }
        
        NSArray* grayImageArr = @[@"weChat_Gray", @"weChat_Moment_Gray", @"qq_Gray", @"qq_Zone_Gray"];
        NSArray* imageArr = @[@"weChat", @"weChat_Moment", @"qq", @"qq_Zone"];
        NSArray* titleArr = @[@"微信好友", @"朋友圈", @"QQ好友", @"QQ空间"];
        CGFloat tempSpaceX = (screenRect.size.width - shareBtnWidth * titleArr.count) / (titleArr.count + 1);
        if (tempSpaceX < 20) {
            tempSpaceX = 20;
        }
        for (NSInteger i = 0; i < titleArr.count; i ++) {
            UIView* view = [[UIView alloc]initWithFrame:CGRectMake((i + 1) * tempSpaceX + shareBtnWidth * i, 0, shareBtnWidth, shareBtnWidth + 10 + 20)];
            [self.scrollView addSubview:view];
            
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, shareBtnWidth, shareBtnWidth + 10 + 20)];
            btn.tag = i;
            [btn addTarget:self action:@selector(clickedItemButton:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
            
            UIView* ivView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, shareBtnWidth, shareBtnWidth)];
            ivView.userInteractionEnabled = NO;
            ivView.backgroundColor = [UIColor whiteColor];
            ivView.layer.cornerRadius = 10;
            ivView.layer.masksToBounds = YES;
            [btn addSubview:ivView];
            
            UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, shareBtnWidth - 20, shareBtnWidth - 20)];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            UIImage* ivImage = [UIImage imageNamed:imageArr[i]];
            [ivView addSubview:iv];
            
            iv.image = ivImage;
            if (!self.hasWeChat && i < 2) {
                iv.image = [UIImage imageNamed:grayImageArr[i]];
            }
            if (!self.hasQQ && (i >= 2 && i < titleArr.count)) {
                iv.image = [UIImage imageNamed:grayImageArr[i]];
            }
            
            UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(-10, shareBtnWidth + 10, shareBtnWidth + 20, 20)];
            lab.font = [UIFont systemFontOfSize:18];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
            lab.text = titleArr[i];
            [view addSubview:lab];
        }
        self.scrollView.contentSize = CGSizeMake((shareBtnWidth + tempSpaceX) * titleArr.count + tempSpaceX, 0);
        
        self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.scrollView.frame.origin.y + self.scrollView.frame.size.height + 30, self.bgView.frame.size.width, 50)];
        self.cancelBtn.backgroundColor = [UIColor whiteColor];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:self.cancelBtn];
    }
    return self;
}

-(void)clickedItemButton:(UIButton* )sender {
    NSInteger tag = sender.tag;
    LMShareViewType type = LMShareViewTypeWeChat;
    if (tag == 0) {
        type = LMShareViewTypeWeChat;
    }else if (tag == 1) {
        type = LMShareViewTypeWeChatMoment;
    }else if (tag == 2) {
        type = LMShareViewTypeQQ;
    }else if (tag == 3) {
        type = LMShareViewTypeQQZone;
    }else if (tag == 4) {
        type = LMShareViewTypeCopyLink;
    }
    if (self.hasWeChat && tag < 2) {
        if (self.shareBlock) {
            self.shareBlock(type);
        }
    }
    if (self.hasQQ && (tag >= 2 && tag < 4)) {
        if (self.shareBlock) {
            self.shareBlock(type);
        }
    }
    
    [self startHide];
}

-(void)clickedCancelButton:(UIButton* )sender {
    [self startHide];
}

-(void)startShow {
    self.alpha = 0;
    self.hidden = NO;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        self.alpha = 1;
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

-(void)startHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate sendSystemNightShiftToback];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    UIView* touchView = touch.view;
    if (touchView != self.bgView) {
        [self startHide];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
