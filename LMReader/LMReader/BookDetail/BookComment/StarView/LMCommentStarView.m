//
//  LMCommentStarView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMCommentStarView.h"

@implementation LMCommentStarView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger btnCount = 5;
        CGFloat btnWidth = frame.size.height;
        CGFloat btnSpace = (float)(frame.size.width - btnWidth * btnCount) / (btnCount - 1);
        for (NSInteger i = 0; i < btnCount; i ++) {
            UIButton* starBtn = [self createButtonWithFrame:CGRectMake((btnSpace + btnWidth) * i, (frame.size.height - btnWidth) / 2, btnWidth, btnWidth) tag:i];
            [self addSubview:starBtn];
        }
    }
    return self;
}

-(UIButton* )createButtonWithFrame:(CGRect )frame tag:(NSInteger )tag {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    [btn setImage:[UIImage imageNamed:@"starGray"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"starFore"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(clickedStarButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    btn.selected = NO;
    return btn;
}

-(void)clickedStarButton:(UIButton* )sender {
    if (self.cancelStar) {
        return;
    }
    NSInteger tag = sender.tag;
    if (sender.selected == YES) {
        for (UIView* subView in self.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton* starBtn = (UIButton* )subView;
                if (starBtn.tag >= tag) {
                    starBtn.selected = NO;
                }
            }
        }
    }else {
        for (UIView* subView in self.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton* starBtn = (UIButton* )subView;
                if (starBtn.tag <= tag) {
                    starBtn.selected = YES;
                }
            }
        }
    }
    NSInteger resultCount = 0;
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton* starBtn = (UIButton* )subView;
            if (starBtn.selected == YES) {
                resultCount ++;
            }
        }
    }
    if (self.starBlock) {
        self.starBlock(resultCount);
    }
}

-(void)setupStarWithCount:(NSInteger)starCount {
    if (starCount <= 0) {
        return;
    }
    NSInteger targetTag = starCount - 1;
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton* starBtn = (UIButton* )subView;
            if (starBtn.tag <= targetTag) {
                starBtn.selected = YES;
            }
        }
    }
}

@end
