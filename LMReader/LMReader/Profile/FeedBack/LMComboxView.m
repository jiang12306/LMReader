//
//  LMComboxView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMComboxView.h"
#import "LMComboxViewTableViewCell.h"
#import "AppDelegate.h"

@interface LMComboxView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIWindow *keyWindow;                ///< 当前窗口
@property (nonatomic, strong) LMBaseAlertView *contentView;     /**<内容层*/
@property (nonatomic, weak) CAShapeLayer *borderLayer;          ///< 边框Layer

#pragma mark - Data
@property (nonatomic, assign) CGFloat windowWidth;   ///< 窗口宽度
@property (nonatomic, assign) CGFloat windowHeight;  ///< 窗口高度
@property (nonatomic, assign) BOOL isUpward;         ///< 箭头指向, YES为向上, 反之为向下, 默认为YES.

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSArray* titleArr;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

float LMComboxViewDegreesToRadians(float angle) {
    return angle*M_PI/180;
}

@implementation LMComboxView

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype )initWithFrame:(CGRect )frame titleArr:(NSArray* )titleArr cellHeight:(CGFloat )cellHeight selectedIndex:(NSInteger )currentIndex {
    // keyWindow
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    _windowWidth = CGRectGetWidth(_keyWindow.bounds);
    _windowHeight = CGRectGetHeight(_keyWindow.bounds);
    
    self = [super initWithFrame:_keyWindow.frame];
    self.backgroundColor = [[UIColor colorWithWhite:0 alpha:1]colorWithAlphaComponent:0.18];
    if (self) {
        _contentView = [[LMBaseAlertView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, cellHeight * titleArr.count)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        
        self.cellHeight = cellHeight;
        self.titleArr = [titleArr copy];
        self.selectedIndex = currentIndex;
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView registerClass:[LMComboxViewTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [_contentView addSubview:self.tableView];
    }
    return self;
}

//
-(void)startShow {
    self.alpha = 0;
    [_keyWindow addSubview:self];
    
    // 弹出动画
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.f;
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

- (void)startHide {
    if (self.cancelBlock) {
        self.cancelBlock(YES);
    }
    
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
        [self startHide];
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMComboxViewTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMComboxViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    cell.contentLab.text = self.titleArr[row];
    
    if (row == self.selectedIndex) {
        cell.clicked = YES;
    }else {
        cell.clicked = NO;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    
    if (row == self.selectedIndex) {
        [self startHide];
        return;
    }
    
    self.selectedIndex = row;
    if (self.callBlock) {
        self.callBlock(self.selectedIndex);
    }
    [self startHide];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
