//
//  LMSourceTitleView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/23.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSourceTitleView.h"
#import "LMTool.h"

@interface LMSourceTitleView ()

@property (nonatomic, strong) UIButton* btn;

@end

@implementation LMSourceTitleView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        self.btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        CGFloat fontSize = 14;//16;
//        if ([LMTool isBangsScreen]) {
//            fontSize = 14;
//        }
        self.btn.backgroundColor = [UIColor blackColor];
        self.btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [self.btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:self.btn];
    }
    return self;
}

-(void)setAlertText:(NSString *)alertText {
    NSString* text = [NSString stringWithFormat:@"本小说来自\"%@\"，点击访问源网站", alertText];
    _alertText = text;
    [self.btn setTitle:text forState:UIControlStateNormal];
}

-(void)clickedButton:(UIButton* )sender {
    if (self.callBlock) {
        self.callBlock(YES);
    }
}

-(void)startShow {
    CGRect originFrame = self.frame;
    CGFloat startY = 64;
    if ([LMTool isBangsScreen]) {
        startY = 88;
    }
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.frame = CGRectMake(0, startY, originFrame.size.width, originFrame.size.height);
    }];
}

-(void)startHide {
    CGRect originFrame = self.frame;
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.frame = CGRectMake(0, 0 - originFrame.size.height, originFrame.size.width, originFrame.size.height);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
