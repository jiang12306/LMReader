//
//  LMCommentStarView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMCommentStarView.h"

@interface LMCommentStarView ()

@property (nonatomic, assign) CGFloat starBtnWidth;
@property (nonatomic, assign) CGFloat starBtnSpace;
@property (nonatomic, strong) UIView* bgView;//底层视图 实心btn
@property (nonatomic, strong) UIView* foreView;//上层视图 空心btn

@end

@implementation LMCommentStarView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger btnCount = 5;
        self.starBtnWidth = frame.size.height;
        self.starBtnSpace = (float)(frame.size.width - self.starBtnWidth * btnCount) / (btnCount - 1);
        
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        self.bgView.backgroundColor = [UIColor clearColor];
        self.bgView.clipsToBounds = YES;
        [self addSubview:self.bgView];
        
        for (NSInteger i = 0; i < btnCount; i ++) {
            UIButton* starBtn = [self createButtonWithFrame:CGRectMake((self.starBtnSpace + self.starBtnWidth) * i, (frame.size.height - self.starBtnWidth) / 2, self.starBtnWidth, self.starBtnWidth) img:[UIImage imageNamed:@"starView_Selected"] tag:i];
            [self.bgView addSubview:starBtn];
        }
        
        self.foreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.foreView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.foreView];
        
        for (NSInteger i = 0; i < btnCount; i ++) {
            UIButton* starBtn = [self createButtonWithFrame:CGRectMake((self.starBtnSpace + self.starBtnWidth) * i, (frame.size.height - self.starBtnWidth) / 2, self.starBtnWidth, self.starBtnWidth) img:[UIImage imageNamed:@"starView_Normal"] tag:i];
            [starBtn addTarget:self action:@selector(clickedForeStarButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.foreView addSubview:starBtn];
        }
    }
    return self;
}

-(UIButton* )createButtonWithFrame:(CGRect )frame img:(UIImage* )img tag:(NSInteger )tag {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    [btn setImage:img forState:UIControlStateNormal];
    btn.tag = tag;
    btn.selected = NO;
    return btn;
}

-(void)clickedForeStarButton:(UIButton* )sender {
    if (self.cancelStar) {
        return;
    }
    NSInteger tag = sender.tag;
    if (sender.selected == YES) {
        for (UIView* subView in self.foreView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton* starBtn = (UIButton* )subView;
                if (starBtn.tag >= tag) {
                    starBtn.selected = NO;
                }
            }
        }
        
        self.bgView.frame = CGRectMake(0, 0, sender.frame.origin.x, self.frame.size.width);
        
    }else {
        for (UIView* subView in self.foreView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton* starBtn = (UIButton* )subView;
                if (starBtn.tag <= tag) {
                    starBtn.selected = YES;
                }
            }
        }
        
        self.bgView.frame = CGRectMake(0, 0, sender.frame.origin.x + sender.frame.size.width, self.frame.size.width);
        
    }
    NSInteger resultCount = 0;
    for (UIView* subView in self.foreView.subviews) {
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
    for (UIView* subView in self.foreView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton* starBtn = (UIButton* )subView;
            if (starBtn.tag <= targetTag) {
                starBtn.selected = YES;
            }
        }
    }
    UIButton* targetSender = [self.foreView viewWithTag:targetTag];
    self.bgView.frame = CGRectMake(0, 0, targetSender.frame.origin.x + targetSender.frame.size.width, self.frame.size.height);
}

-(void)setupStarWithFloatCount:(float)starCount {
    if (starCount <= 0) {
        return;
    }
    NSInteger targetTag = 0;
    //4.0   4.2   4.5   4.8
    int starInt = roundf(starCount);
    float tempFloat = starInt - starCount;
    if (tempFloat == 0) {//4.0
        targetTag = starInt - 1;
        UIButton* targetSender = [self.foreView viewWithTag:targetTag];
        self.bgView.frame = CGRectMake(0, 0, targetSender.frame.origin.x + targetSender.frame.size.width, self.frame.size.height);
    }else if (tempFloat < 0) {//>=4.2 半颗星
        targetTag = starInt;
        UIButton* targetSender = [self.foreView viewWithTag:targetTag];
        self.bgView.frame = CGRectMake(0, 0, targetSender.frame.origin.x + targetSender.frame.size.width / 2, self.frame.size.height);
    }else if (tempFloat > 0) {
        targetTag = starInt - 1;
        if (tempFloat == 0.5) {//4.5
            UIButton* targetSender = [self.foreView viewWithTag:targetTag];
            self.bgView.frame = CGRectMake(0, 0, targetSender.frame.origin.x + targetSender.frame.size.width / 2, self.frame.size.height);
        }else {//4.8
            UIButton* targetSender = [self.foreView viewWithTag:targetTag];
            self.bgView.frame = CGRectMake(0, 0, targetSender.frame.origin.x + targetSender.frame.size.width, self.frame.size.height);
        }
    }else {//否则 5星
        targetTag = 4;
        UIButton* targetSender = [self.foreView viewWithTag:targetTag];
        self.bgView.frame = CGRectMake(0, 0, targetSender.frame.origin.x + targetSender.frame.size.width, self.frame.size.height);
    }
}

@end
