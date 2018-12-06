//
//  LMSearchHelpBottomAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/23.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMSearchHelpBottomAlertView.h"

@interface LMSearchHelpBottomAlertView ()

@property (nonatomic, strong) UIButton* titleBtn;

@end

@implementation LMSearchHelpBottomAlertView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, frame.size.width - 20 * 2, frame.size.height)];
        self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleBtn.titleLabel.numberOfLines = 0;
        self.titleBtn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.titleBtn setTitleColor:[UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1] forState:UIControlStateNormal];
        [self.titleBtn setTitle:@"没找到？让夜色小管家帮你找" forState:UIControlStateNormal];
        [self.titleBtn addTarget:self action:@selector(clickedTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.titleBtn];
    }
    return self;
}

-(void)clickedTitleButton:(UIButton* )sender {
    if (self.clickBlock) {
        self.clickBlock(YES);
    }
}

@end
