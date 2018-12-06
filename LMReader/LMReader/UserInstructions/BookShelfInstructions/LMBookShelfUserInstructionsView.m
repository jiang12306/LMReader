//
//  LMBookShelfUserInstructionsView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/5.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfUserInstructionsView.h"
#import "LMTool.h"

@implementation LMBookShelfUserInstructionsView

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

-(void)startShowWithBookPoint:(CGPoint)bookPoint {
    //
    [LMTool updateSetShowBookShelfUserInstructionsView];
    
    UIImageView* pressIV = [[UIImageView alloc]initWithFrame:CGRectMake(bookPoint.x - 70, bookPoint.y - 140 *0.15, 140, 140)];
    pressIV.image = [UIImage imageNamed:@"userInstructions_BookShelf"];
    [self addSubview:pressIV];
    
    self.alpha = 0;
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
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
        [LMTool updateSetShowBookShelfUserInstructionsView];
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
