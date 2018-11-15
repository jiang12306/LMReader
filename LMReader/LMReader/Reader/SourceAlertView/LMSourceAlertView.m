//
//  LMSourceAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/23.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSourceAlertView.h"
#import "AppDelegate.h"

@interface LMSourceAlertView ()

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* textLab;
@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) UIButton* sureBtn;
@property (nonatomic, strong) UIButton* cancelBtn;

@end

@implementation LMSourceAlertView

-(instancetype)initWithFrame:(CGRect)frame text:(NSString* )text sourceName:(NSString* )sourceName {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width - 100, screenRect.size.width)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.contentView.frame.size.width, 20)];
        self.titleLab.font = [UIFont boldSystemFontOfSize:18];
        self.titleLab.text = @"提示";
        [self.contentView addSubview:self.titleLab];
        
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(20, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 20, self.contentView.frame.size.width - 20 * 2, 0)];
        self.textLab.font = [UIFont systemFontOfSize:15];
        self.textLab.numberOfLines = 0;
        self.textLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.textLab.text = [NSString stringWithFormat:@"来源网址：%@", text];
        CGSize textSize = [self.textLab sizeThatFits:CGSizeMake(self.contentView.frame.size.width - 20 * 2, CGFLOAT_MAX)];
        CGFloat maxHeight = textSize.height;
        if (maxHeight > screenRect.size.height - 200) {
            maxHeight = screenRect.size.height - 200;
        }
        self.textLab.frame = CGRectMake(20, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 20, textSize.width, maxHeight);
        [self.contentView addSubview:self.textLab];
        
        self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(20, self.textLab.frame.origin.y + self.textLab.frame.size.height + 20, self.contentView.frame.size.width - 20 * 2, 40)];
        self.infoLab.font = [UIFont systemFontOfSize:15];
        self.infoLab.numberOfLines = 0;
        self.infoLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.infoLab.text = [NSString stringWithFormat:@"此书籍来源于\"%@\"，如有侵权请联系屏蔽，谢谢", sourceName];
        CGSize infoSize = [self.infoLab sizeThatFits:CGSizeMake(self.contentView.frame.size.width - 20 * 2, CGFLOAT_MAX)];
        self.infoLab.frame = CGRectMake(20, self.textLab.frame.origin.y + self.textLab.frame.size.height + 20, self.contentView.frame.size.width - 20 * 2, infoSize.height);
        [self.contentView addSubview:self.infoLab];
        
        self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width - 20 - 40, self.infoLab.frame.origin.y + self.infoLab.frame.size.height + 20, 40, 20)];
        self.cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [self.cancelBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelBtn];
        
        self.sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.cancelBtn.frame.origin.x - 15 - 85, self.cancelBtn.frame.origin.y, 85, self.cancelBtn.frame.size.height)];
        self.sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [self.sureBtn setTitleColor:[UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1] forState:UIControlStateNormal];
        [self.sureBtn setTitle:@"打开源网页" forState:UIControlStateNormal];
        [self.sureBtn addTarget:self action:@selector(clickedSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.sureBtn];
        
        self.contentView.frame = CGRectMake(0, 0, screenRect.size.width - 100, self.sureBtn.frame.origin.y + self.sureBtn.frame.size.height + 20);
        self.contentView.center = self.center;
    }
    return self;
}

-(void)clickedSureButton:(UIButton* )sender {
    if (self.sureBlock) {
        self.sureBlock(YES);
    }
    
    [self startHide];
}

-(void)clickedCancelButton:(UIButton* )sender {
    if (self.cancelBlock) {
        self.cancelBlock(YES);
    }
    
    [self startHide];
}

-(void)startShow {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

-(void)startHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate sendSystemNightShiftToback];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    bool isContain = CGRectContainsPoint(self.contentView.frame, point);
    if (!isContain) {
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
