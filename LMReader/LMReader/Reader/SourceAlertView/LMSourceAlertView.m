//
//  LMSourceAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/23.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSourceAlertView.h"

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
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width - 100, screenRect.size.width)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 50)];
        self.titleLab.font = [UIFont boldSystemFontOfSize:18];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.text = @"温馨提示";
        [self.contentView addSubview:self.titleLab];
        
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, self.contentView.frame.size.width - 20, 0)];
        self.textLab.font = [UIFont systemFontOfSize:16];
        self.textLab.numberOfLines = 0;
        self.textLab.textAlignment = NSTextAlignmentCenter;
        self.textLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.textLab.text = [NSString stringWithFormat:@"将跳转至源网址%@", text];
        CGSize textSize = [self.textLab sizeThatFits:CGSizeMake(self.contentView.frame.size.width - 20, CGFLOAT_MAX)];
        CGFloat maxHeight = textSize.height;
        if (maxHeight > screenRect.size.height - 200) {
            maxHeight = screenRect.size.height - 200;
        }
        self.textLab.frame = CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, textSize.width, maxHeight);
        [self.contentView addSubview:self.textLab];
        
        self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.textLab.frame.origin.y + self.textLab.frame.size.height + 10, self.contentView.frame.size.width - 20, 40)];
        self.infoLab.font = [UIFont systemFontOfSize:16];
        self.infoLab.numberOfLines = 0;
        self.infoLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.infoLab.textAlignment = NSTextAlignmentCenter;
        self.infoLab.text = [NSString stringWithFormat:@"本小说来自\"%@\"，如有侵权请联系屏蔽，谢谢。", sourceName];
        CGSize infoSize = [self.infoLab sizeThatFits:CGSizeMake(self.contentView.frame.size.width - 20, CGFLOAT_MAX)];
        self.infoLab.frame = CGRectMake(10, self.textLab.frame.origin.y + self.textLab.frame.size.height + 10, self.contentView.frame.size.width - 20, infoSize.height);
        [self.contentView addSubview:self.infoLab];
        
        self.sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.infoLab.frame.origin.y + self.infoLab.frame.size.height + 15, self.contentView.frame.size.width / 2, 40)];
        [self.sureBtn setTitleColor:[UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1] forState:UIControlStateNormal];
        [self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.sureBtn addTarget:self action:@selector(clickedSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.sureBtn];
        
        self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.sureBtn.frame.size.width, self.sureBtn.frame.origin.y, self.sureBtn.frame.size.width, self.sureBtn.frame.size.height)];
        [self.cancelBtn setTitleColor:[UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1] forState:UIControlStateNormal];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelBtn];
        
        CALayer* hLayer = [CALayer layer];
        hLayer.frame = CGRectMake(0, self.sureBtn.frame.origin.y, self.contentView.frame.size.width, 0.3);
        hLayer.backgroundColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1].CGColor;
        [self.contentView.layer addSublayer:hLayer];
        
        CALayer* vLayer = [CALayer layer];
        vLayer.frame = CGRectMake(self.sureBtn.frame.size.width, self.sureBtn.frame.origin.y, 0.5, self.sureBtn.frame.size.height);
        vLayer.backgroundColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1].CGColor;
        [self.contentView.layer addSublayer:vLayer];
        
        self.contentView.frame = CGRectMake(0, 0, screenRect.size.width - 100, self.sureBtn.frame.origin.y + self.sureBtn.frame.size.height);
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
}

-(void)startHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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
