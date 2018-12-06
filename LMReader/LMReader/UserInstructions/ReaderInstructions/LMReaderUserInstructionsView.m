//
//  LMReaderUserInstructionsView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/6.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMReaderUserInstructionsView.h"
#import "LMTool.h"

typedef enum {
    LMReaderUserInstructionsViewType1 = 1,
    LMReaderUserInstructionsViewType2 = 2,
    LMReaderUserInstructionsViewType3 = 3,
}LMReaderUserInstructionsViewType;

@interface LMReaderUserInstructionsView ()

@property (nonatomic, assign) LMReaderUserInstructionsViewType type;
@property (nonatomic, strong) UIButton* stepOverBtn;
@property (nonatomic, assign) CGPoint sourcePoint;
@property (nonatomic, assign) CGPoint nightPoint;
@property (nonatomic, assign) CGPoint commentPoint;
@property (nonatomic, assign) CGPoint settingPoint;
@property (nonatomic, assign) CGPoint errorPoint;

@end

@implementation LMReaderUserInstructionsView

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
        
        self.type = LMReaderUserInstructionsViewType1;
        if ([LMTool shouldShowReaderUserInstructionsView1]) {
            self.type = LMReaderUserInstructionsViewType1;
        }else if ([LMTool shouldShowReaderUserInstructionsView2]) {
            self.type = LMReaderUserInstructionsViewType2;
        }else if ([LMTool shouldShowReaderUserInstructionsView3]) {
            self.type = LMReaderUserInstructionsViewType3;
        }
        
        CGFloat tabBarHeight = 49;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
        }
        
        self.stepOverBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenRect.size.width - 131.5) / 2, screenRect.size.height - tabBarHeight - 30 - 48.5, 131.5, 48.5)];
        self.stepOverBtn.backgroundColor = [UIColor clearColor];
        [self.stepOverBtn setImage:[UIImage imageNamed:@"userInstructions_StepOver"] forState:UIControlStateNormal];
        [self.stepOverBtn addTarget:self action:@selector(clickedStepOverButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.stepOverBtn];
        
        UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedView:)];
        [self addGestureRecognizer:tapGR];
        
        UISwipeGestureRecognizer* swipeGR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swippedView:)];
        swipeGR.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeGR];
    }
    return self;
}

-(void)tappedView:(UITapGestureRecognizer* )tapGR {
    [self nextUserInstructionsView];
}

-(void)swippedView:(UISwipeGestureRecognizer* )swipeGR {
    [self nextUserInstructionsView];
}

-(void)nextUserInstructionsView {
    if (self.type == LMReaderUserInstructionsViewType1) {
        self.type = LMReaderUserInstructionsViewType2;
        [self reloadAllSubviews];
    }else if (self.type == LMReaderUserInstructionsViewType2) {self.type = LMReaderUserInstructionsViewType3;
        [self reloadAllSubviews];
    }else if (self.type == LMReaderUserInstructionsViewType3) {
        [self clickedStepOverButton:nil];
    }else {
        [self clickedStepOverButton:nil];
    }
}

-(void)clickedStepOverButton:(UIButton* )sender {
    [LMTool updateSetShowReaderUserInstructionsView1];
    [LMTool updateSetShowReaderUserInstructionsView2];
    [LMTool updateSetShowReaderUserInstructionsView3];
    [LMTool updateSetShowReaderUserInstructionsView];
    
    [self startHide];
}

//刷新所有视图
-(void)reloadAllSubviews {
    for (UIView* subVi in self.subviews) {
        if (subVi != self.stepOverBtn) {
            [subVi removeFromSuperview];
        }
    }
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    if (self.type == LMReaderUserInstructionsViewType1) {
        [LMTool updateSetShowReaderUserInstructionsView1];
        
        UIImageView* sourceArrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.sourcePoint.x - 25, self.sourcePoint.y, 45, 95)];
        sourceArrowIV.image = [UIImage imageNamed:@"userInstructions_Reader_RightArrow"];
        [self addSubview:sourceArrowIV];
        
        CGFloat sourceWidth = 325;
        CGFloat sourceHeight = 28;
        if (sourceWidth > keyWindow.bounds.size.width) {
            sourceHeight = keyWindow.bounds.size.width / sourceWidth * sourceHeight;
            sourceWidth = keyWindow.bounds.size.width;
        }
        UIImageView* sourceIV = [[UIImageView alloc]initWithFrame:CGRectMake((keyWindow.bounds.size.width - sourceWidth) / 2, sourceArrowIV.frame.origin.y + sourceArrowIV.frame.size.height, sourceWidth, sourceHeight)];
        sourceIV.image = [UIImage imageNamed:@"userInstructions_Reader_Source"];
        [self addSubview:sourceIV];
        
        
        UIImageView* nightArrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.nightPoint.x - 45, self.nightPoint.y - 95, 45, 95)];
        nightArrowIV.image = [UIImage imageNamed:@"userInstructions_Reader_LeftArrow"];
        [self addSubview:nightArrowIV];
        
        CGFloat nightWidth = 155;
        CGFloat nightHeight = 28;
        UIImageView* nightIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, nightArrowIV.frame.origin.y - nightHeight, nightWidth, nightHeight)];
        nightIV.image = [UIImage imageNamed:@"userInstructions_Reader_Night"];
        [self addSubview:nightIV];
        
        CGRect btnFrame = self.stepOverBtn.frame;
        btnFrame.origin.x = keyWindow.frame.size.width - btnFrame.size.width - 20;
        btnFrame.origin.y = nightIV.frame.origin.y - btnFrame.size.height;
        self.stepOverBtn.frame = btnFrame;
    }else if (self.type == LMReaderUserInstructionsViewType2) {
        [LMTool updateSetShowReaderUserInstructionsView1];
        [LMTool updateSetShowReaderUserInstructionsView2];
        
        UIImageView* commentArrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.commentPoint.x - 25, self.commentPoint.y - 95, 45, 95)];
        commentArrowIV.image = [UIImage imageNamed:@"userInstructions_Reader_DownArrow"];
        [self addSubview:commentArrowIV];
        
        CGFloat commentWidth = 215;
        CGFloat commentHeight = 28;
        UIImageView* commentIV = [[UIImageView alloc]initWithFrame:CGRectMake(commentArrowIV.frame.origin.x - commentWidth, commentArrowIV.frame.origin.y - commentHeight / 2, commentWidth, commentHeight)];
        commentIV.image = [UIImage imageNamed:@"userInstructions_Reader_Comment"];
        [self addSubview:commentIV];
        
        
        UIImageView* settingArrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.settingPoint.x, self.settingPoint.y - 95, 45, 95)];
        settingArrowIV.image = [UIImage imageNamed:@"userInstructions_Reader_RightArrow"];
        [self addSubview:settingArrowIV];
        
        CGFloat settingWidth = 265;
        CGFloat settingHeight = 28;
        UIImageView* settingIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, settingArrowIV.frame.origin.y - settingHeight, settingWidth, settingHeight)];
        settingIV.image = [UIImage imageNamed:@"userInstructions_Reader_Setting"];
        [self addSubview:settingIV];
        
        CGRect btnFrame = self.stepOverBtn.frame;
        btnFrame.origin.x = keyWindow.frame.size.width - btnFrame.size.width - 20;
        btnFrame.origin.y = 70;
        self.stepOverBtn.frame = btnFrame;
    }else if (self.type == LMReaderUserInstructionsViewType3) {
        [LMTool updateSetShowReaderUserInstructionsView1];
        [LMTool updateSetShowReaderUserInstructionsView2];
        [LMTool updateSetShowReaderUserInstructionsView3];
        [LMTool updateSetShowReaderUserInstructionsView];
        
        UIImageView* errorArrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.errorPoint.x, self.errorPoint.y - 95, 45, 95)];
        errorArrowIV.image = [UIImage imageNamed:@"userInstructions_Reader_RightArrow"];
        [self addSubview:errorArrowIV];
        
        CGFloat errorWidth = 365;
        CGFloat errorHeight = 28;
        if (errorWidth > keyWindow.bounds.size.width) {
            errorHeight = keyWindow.bounds.size.width / errorWidth * errorHeight;
            errorWidth = keyWindow.bounds.size.width;
        }
        UIImageView* errorIV = [[UIImageView alloc]initWithFrame:CGRectMake((keyWindow.bounds.size.width - errorWidth) / 2, errorArrowIV.frame.origin.y - errorHeight, errorWidth, errorHeight)];
        errorIV.image = [UIImage imageNamed:@"userInstructions_Reader_FeedBack"];
        [self addSubview:errorIV];
        
        CGRect btnFrame = self.stepOverBtn.frame;
        btnFrame.origin.x = keyWindow.frame.size.width - btnFrame.size.width - 20;
        btnFrame.origin.y = 70;
        self.stepOverBtn.frame = btnFrame;
    }else {
        [LMTool updateSetShowReaderUserInstructionsView1];
        [LMTool updateSetShowReaderUserInstructionsView2];
        [LMTool updateSetShowReaderUserInstructionsView3];
        [LMTool updateSetShowReaderUserInstructionsView];
    }
}

-(void)startHide {
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//设置“换源”、“夜间”按钮位置
-(void)setUpChangeSourcePoint:(CGPoint )sourcePoint nightPoint:(CGPoint )nightPoint {
    self.sourcePoint = sourcePoint;
    self.nightPoint = nightPoint;
}

//设置“书评”、“设置”按钮位置
-(void)setUpCommentPoint:(CGPoint )commentPoint SettingPoint:(CGPoint )settingPoint {
    self.commentPoint = commentPoint;
    self.settingPoint = settingPoint;
}

//设置“报错”按钮位置
-(void)setUpErrorPoint:(CGPoint )errorPoint {
    self.errorPoint = errorPoint;
}

//
-(void)startShow {
    [self reloadAllSubviews];
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    self.alpha = 0;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
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
