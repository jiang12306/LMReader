//
//  LMSearchUserInstructionsView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/5.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMSearchUserInstructionsView.h"
#import "LMTool.h"

@implementation LMSearchUserInstructionsView

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
        
        CGFloat tabBarHeight = 49;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
        }
        
        UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedView:)];
        [self addGestureRecognizer:tapGR];
        
        UISwipeGestureRecognizer* swipeGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swippedView:)];
        swipeGR.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeGR];
        
        UIButton* stepOverBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenRect.size.width - 131.5) / 2, screenRect.size.height - tabBarHeight - 30 - 48.5, 131.5, 48.5)];
        stepOverBtn.backgroundColor = [UIColor clearColor];
        [stepOverBtn setImage:[UIImage imageNamed:@"userInstructions_StepOver"] forState:UIControlStateNormal];
        [stepOverBtn addTarget:self action:@selector(clickedStepOverButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stepOverBtn];
    }
    return self;
}

-(void)tappedView:(UITapGestureRecognizer* )tapGR {
    [self startHide];
}

-(void)swippedView:(UISwipeGestureRecognizer* )swipeGR {
    [self startHide];
}

-(void)clickedStepOverButton:(UIButton* )sender {
    [self startHide];
}

-(void)startShowWithStartPoint:(CGPoint)startPoint {
    //
    [LMTool updateSetShowSearchUserInstructionsView];
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIImageView* arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(startPoint.x - 45 - 20, startPoint.y, 45, 95)];
    arrowIV.image = [UIImage imageNamed:@"userInstructions_Search_Arrow"];
    [self addSubview:arrowIV];
    
    CGFloat pressWidth = 325;
    CGFloat pressHeight = 28;
    if (pressWidth > keyWindow.bounds.size.width) {
        pressHeight = keyWindow.bounds.size.width / pressWidth * pressHeight;
        pressWidth = keyWindow.bounds.size.width;
    }
    UIImageView* pressIV = [[UIImageView alloc]initWithFrame:CGRectMake((keyWindow.bounds.size.width - pressWidth) / 2, arrowIV.frame.origin.y + arrowIV.frame.size.height, pressWidth, pressHeight)];
    pressIV.image = [UIImage imageNamed:@"userInstructions_Search_Help"];
    [self addSubview:pressIV];
    
    self.alpha = 0;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)startHide {
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [LMTool updateSetShowSearchUserInstructionsView];
    }];
}

@end
