//
//  LMAuthorBookFilterListView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/18.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMAuthorBookFilterListView.h"
#import "AppDelegate.h"

static CGFloat const kPopoverViewMargin = 8.f;        ///< 边距
static CGFloat const kPopoverViewArrowHeight = 13.f;  ///< 箭头高度

float LMAuthorBookPopoverViewDegreesToRadians(float angle) {
    return angle*M_PI/180;
}

@interface LMAuthorBookFilterListView ()

@property (nonatomic, weak) UIWindow *keyWindow;                ///< 当前窗口
@property (nonatomic, strong) LMBaseAlertView *contentView;
@property (nonatomic, weak) CAShapeLayer *borderLayer;          ///< 边框Layer

#pragma mark - Data
@property (nonatomic, assign) CGFloat windowWidth;   ///< 窗口宽度
@property (nonatomic, assign) CGFloat windowHeight;  ///< 窗口高度
@property (nonatomic, assign) BOOL isUpward;         ///< 箭头指向, YES为向上, 反之为向下, 默认为YES.

@end

@implementation LMAuthorBookFilterListView

- (instancetype)initWithFrame:(CGRect)frame
{
    // keyWindow
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    _windowWidth = CGRectGetWidth(_keyWindow.bounds);
    _windowHeight = CGRectGetHeight(_keyWindow.bounds);
    
    self = [super initWithFrame:_keyWindow.frame];
    if (!self) {
        return nil;
    }
    
    _contentView = [[LMBaseAlertView alloc] initWithFrame:frame];
    
    [self initialize];
    return self;
}



- (void)initialize
{
    // data
    _isUpward = YES;
    
    // current view
    _contentView.backgroundColor = [UIColor whiteColor];
    [self setShowShade:YES];
    
    
    CGFloat startY = 10 + kPopoverViewArrowHeight;
    UILabel* lineLab = [[UILabel alloc]initWithFrame:CGRectMake(10, startY, 5, 20)];
    lineLab.layer.cornerRadius = 2.5;
    lineLab.layer.masksToBounds = YES;
    lineLab.backgroundColor = THEMEORANGECOLOR;
    [_contentView addSubview:lineLab];
    
    UILabel* textLab = [[UILabel alloc]initWithFrame:CGRectMake(lineLab.frame.origin.x + lineLab.frame.size.width + 5, startY, 60, 20)];
    textLab.font = [UIFont boldSystemFontOfSize:18];
    textLab.text = @"状态";
    [_contentView addSubview:textLab];
    
    self.allBtn = [self createItemButtonWithFrame:CGRectMake(10, 40 + kPopoverViewArrowHeight, 40, 30) title:@"全部" selected:NO selector:@selector(clickedStateButton:)];
    [_contentView addSubview:self.allBtn];
    
    self.finishBtn = [self createItemButtonWithFrame:CGRectMake(self.allBtn.frame.origin.x + self.allBtn.frame.size.width + 10, self.allBtn.frame.origin.y, 40, 30) title:@"完结" selected:NO selector:@selector(clickedStateButton:)];
    [_contentView addSubview:self.finishBtn];
    
    self.loadBtn = [self createItemButtonWithFrame:CGRectMake(self.finishBtn.frame.origin.x + self.finishBtn.frame.size.width + 10, self.allBtn.frame.origin.y, 60, 30) title:@"连载中" selected:NO selector:@selector(clickedStateButton:)];
    [_contentView addSubview:self.loadBtn];
}

-(void)setBookState:(LMBookStoreState)bookState {
    self.allBtn.selected = NO;
    self.finishBtn.selected = NO;
    self.loadBtn.selected = NO;
    if (bookState == LMBookStoreStateAll) {
        self.allBtn.selected = YES;
        self.allBtn.layer.borderColor = THEMEORANGECOLOR.CGColor;
    }else if (bookState == LMBookStoreStateFinished) {
        self.finishBtn.selected = YES;
        self.finishBtn.layer.borderColor = THEMEORANGECOLOR.CGColor;
    }else if (bookState == LMBookStoreStateLoad) {
        self.loadBtn.selected = YES;
        self.loadBtn.layer.borderColor = THEMEORANGECOLOR.CGColor;
    }
    _bookState = bookState;
}

-(void)clickedStateButton:(UIButton* )sender {
    if (sender.isSelected) {
        [self hide];
        return;
    }
    self.allBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.finishBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.loadBtn.layer.borderColor = [UIColor grayColor].CGColor;
    sender.layer.borderColor = THEMEORANGECOLOR.CGColor;
    
    LMBookStoreState resultState = LMBookStoreStateAll;
    if (sender == self.allBtn) {
        self.allBtn.selected = YES;
        self.finishBtn.selected = NO;
        self.loadBtn.selected = NO;
    }else if (sender == self.finishBtn) {
        self.allBtn.selected = NO;
        self.finishBtn.selected = YES;
        self.loadBtn.selected = NO;
        resultState = LMBookStoreStateFinished;
    }else if (sender == self.loadBtn) {
        self.allBtn.selected = NO;
        self.finishBtn.selected = NO;
        self.loadBtn.selected = YES;
        resultState = LMBookStoreStateLoad;
    }
    if (self.stateBlock) {
        self.stateBlock(resultState);
    }
    [self hide];
}

-(UIButton* )createItemButtonWithFrame:(CGRect )frame title:(NSString* )title selected:(BOOL )selected selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    btn.layer.cornerRadius = 3;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = .5;
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:THEMEORANGECOLOR forState:UIControlStateSelected];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.selected = selected;
    if (selected) {
        btn.layer.borderColor = THEMEORANGECOLOR.CGColor;
    }else {
        btn.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return btn;
}

- (void)setShowShade:(BOOL)showShade
{
    if (showShade) {
        self.backgroundColor = [[UIColor colorWithWhite:0 alpha:1]colorWithAlphaComponent:0.18];
    }else {
        self.backgroundColor = [UIColor clearColor];
    }
    if (_borderLayer) {
        _borderLayer.strokeColor = showShade ? [UIColor clearColor].CGColor : [UIColor grayColor].CGColor;
    }
}

- (void)showToView:(UIView *)pointView {
    // 判断 pointView 是偏上还是偏下
    CGRect pointViewRect = [pointView.superview convertRect:pointView.frame toView:_keyWindow];
    CGFloat pointViewUpLength = CGRectGetMinY(pointViewRect);
    CGFloat pointViewDownLength = _windowHeight - CGRectGetMaxY(pointViewRect);
    // 弹窗箭头指向的点
    CGPoint toPoint = CGPointMake(CGRectGetMidX(pointViewRect), 0);
    // 弹窗在 pointView 顶部
    if (pointViewUpLength > pointViewDownLength) {
        toPoint.y = pointViewUpLength - 5;
    }
    // 弹窗在 pointView 底部
    else {
        toPoint.y = CGRectGetMaxY(pointViewRect) + 5;
    }
    
    // 箭头指向方向
    _isUpward = pointViewUpLength <= pointViewDownLength;
    
    [self showToPoint:toPoint];
}

/**
 显示弹窗指向某个点
 */
- (void)showToPoint:(CGPoint)toPoint
{
    // 截取弹窗时相关数据
    CGFloat arrowWidth = 28;
    CGFloat cornerRadius = 6.f;
    CGFloat arrowCornerRadius = 2.5f;
    CGFloat arrowBottomCornerRadius = 4.f;
    
    // 如果箭头指向的点过于偏左或者过于偏右则需要重新调整箭头 x 轴的坐标
    CGFloat minHorizontalEdge = kPopoverViewMargin + cornerRadius + arrowWidth/2 + 2;
    if (toPoint.x < minHorizontalEdge) {
        toPoint.x = minHorizontalEdge;
    }
    if (_windowWidth - toPoint.x < minHorizontalEdge) {
        toPoint.x = _windowWidth - minHorizontalEdge;
    }
    
    // 遮罩层
    self.alpha = 0.f;
    [_keyWindow addSubview:self];
    
    // 根据刷新后的ContentSize和箭头指向方向来设置当前视图的frame
    CGFloat currentW = self.contentView.frame.size.width; // 宽度通过计算获取最大值
    CGFloat currentH = self.contentView.frame.size.height;
    
    // 箭头高度
    currentH += kPopoverViewArrowHeight;
    
    CGFloat currentX = toPoint.x - currentW/2, currentY = toPoint.y;
    // x: 窗口靠左
    if (toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = kPopoverViewMargin;
    }
    // x: 窗口靠右
    if (_windowWidth - toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = _windowWidth - kPopoverViewMargin - currentW;
    }
    // y: 箭头向下
    if (!_isUpward) {
        currentY = toPoint.y - currentH;
    }
    
    self.contentView.frame = CGRectMake(currentX, currentY, currentW, currentH);
    
    // 截取箭头
    CGPoint arrowPoint = CGPointMake(toPoint.x - CGRectGetMinX(self.contentView.frame), _isUpward ? 0 : currentH); // 箭头顶点在当前视图的坐标
    CGFloat maskTop = _isUpward ? kPopoverViewArrowHeight : 0; // 顶部Y值
    CGFloat maskBottom = _isUpward ? currentH : currentH - kPopoverViewArrowHeight; // 底部Y值
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    // 左上圆角
    [maskPath moveToPoint:CGPointMake(0, cornerRadius + maskTop)];
    [maskPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius + maskTop)
                        radius:cornerRadius
                    startAngle:LMAuthorBookPopoverViewDegreesToRadians(180)
                      endAngle:LMAuthorBookPopoverViewDegreesToRadians(270)
                     clockwise:YES];
    // 箭头向上时的箭头位置
    if (_isUpward) {
        
        [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, kPopoverViewArrowHeight)];
        
        
        [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, arrowCornerRadius)
                         controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, kPopoverViewArrowHeight)];
        [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, arrowCornerRadius)
                         controlPoint:arrowPoint];
        [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, kPopoverViewArrowHeight)
                         controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, kPopoverViewArrowHeight)];
        
    }
    // 右上圆角
    [maskPath addLineToPoint:CGPointMake(currentW - cornerRadius, maskTop)];
    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskTop + cornerRadius)
                        radius:cornerRadius
                    startAngle:LMAuthorBookPopoverViewDegreesToRadians(270)
                      endAngle:LMAuthorBookPopoverViewDegreesToRadians(0)
                     clockwise:YES];
    // 右下圆角
    [maskPath addLineToPoint:CGPointMake(currentW, maskBottom - cornerRadius)];
    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskBottom - cornerRadius)
                        radius:cornerRadius
                    startAngle:LMAuthorBookPopoverViewDegreesToRadians(0)
                      endAngle:LMAuthorBookPopoverViewDegreesToRadians(90)
                     clockwise:YES];
    
    // 左下圆角
    [maskPath addLineToPoint:CGPointMake(cornerRadius, maskBottom)];
    [maskPath addArcWithCenter:CGPointMake(cornerRadius, maskBottom - cornerRadius)
                        radius:cornerRadius
                    startAngle:LMAuthorBookPopoverViewDegreesToRadians(90)
                      endAngle:LMAuthorBookPopoverViewDegreesToRadians(180)
                     clockwise:YES];
    [maskPath closePath];
    // 截取圆角和箭头
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentView.layer.mask = maskLayer;
    // 边框 (只有在不显示半透明阴影层时才设置边框线条)
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.frame = self.contentView.bounds;
    borderLayer.path = maskPath.CGPath;
    borderLayer.lineWidth = 1;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor grayColor].CGColor;
    [self.contentView.layer addSublayer:borderLayer];
    _borderLayer = borderLayer;
    
    [self addSubview:self.contentView];
    
    // 弹出动画
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.f;
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

/**
 点击外部隐藏弹窗
 */
- (void)hide
{
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.contentView removeFromSuperview];
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
        [self hide];
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
