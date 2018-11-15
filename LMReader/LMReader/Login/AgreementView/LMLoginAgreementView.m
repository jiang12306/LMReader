//
//  LMLoginAgreementView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/27.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMLoginAgreementView.h"

@interface LMLoginAgreementView ()

@property (nonatomic, strong) UIButton* agreeBtn;
@property (nonatomic, strong) UIButton* protocolBtn;

@end

@implementation LMLoginAgreementView

static CGFloat agreeButtonHeight = 15;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.agreeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, (frame.size.height - agreeButtonHeight) / 2, agreeButtonHeight, agreeButtonHeight)];
        [self.agreeBtn setImage:[UIImage imageNamed:@"readPreferences_Normal"] forState:UIControlStateNormal];
        [self.agreeBtn setImage:[UIImage imageNamed:@"readPreferences_Selected"] forState:UIControlStateSelected];
        self.agreeBtn.selected = YES;
        [self.agreeBtn addTarget:self action:@selector(clickedAgreeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.agreeBtn];
        
        NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithString:@"同意《用户隐私协议》"];
        [attributedStr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont systemFontOfSize:12]} range:NSMakeRange(0, 2)];
        [attributedStr addAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : [UIFont systemFontOfSize:12], NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:NSMakeRange(2, attributedStr.length - 2)];
        
        self.protocolBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.agreeBtn.frame.origin.x + self.agreeBtn.frame.size.width, self.agreeBtn.frame.origin.y, frame.size.width - 20, agreeButtonHeight)];
        [self.protocolBtn setAttributedTitle:attributedStr forState:UIControlStateNormal];
        [self.protocolBtn addTarget:self action:@selector(clickedProtocolButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.protocolBtn];
    }
    return self;
}

-(void)clickedAgreeButton:(UIButton* )sender {
    self.agreeBtn.selected = !self.agreeBtn.selected;
    
    BOOL result = NO;
    if (self.agreeBtn.selected == YES) {
        result = YES;
    }
    if (self.agreeBlock) {
        self.agreeBlock(result);
    }
}

-(void)clickedProtocolButton:(UIButton* )sender {
    if (self.clickBlock) {
        self.clickBlock(YES);
    }
}


@end
