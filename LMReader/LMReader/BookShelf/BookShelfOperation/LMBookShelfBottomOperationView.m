//
//  LMBookShelfBottomOperationView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfBottomOperationView.h"
#import "LMBookShelfBottomOperationTableViewCell.h"
#import "AppDelegate.h"
#import "LMTool.h"

@interface LMBookShelfBottomOperationView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UITableView* tableView;

@end

@implementation LMBookShelfBottomOperationView

CGFloat operationCellHeight = 60;
static NSString* bottomCellIdentifier = @"bottomCellIdentifier";

-(instancetype)initWithFrame:(CGRect)frame imgsArr:(NSArray *)imgsArr titleArr:(NSArray *)titleArr {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        self.imgsArray = [NSArray arrayWithArray:imgsArr];
        self.titleArray = [NSArray arrayWithArray:titleArr];
        
        CGFloat contentHeight = self.titleArray.count * operationCellHeight;
        if (contentHeight > screenRect.size.height - 100) {
            contentHeight = screenRect.size.height - 100;
        }
        CGFloat viewHeight = contentHeight;
        if ([LMTool isBangsScreen]) {
            viewHeight += 44;
        }
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height - viewHeight, screenRect.size.width, viewHeight)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentView];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, contentHeight) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor whiteColor];
        if (@available(ios 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
        }
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[LMBookShelfBottomOperationTableViewCell class] forCellReuseIdentifier:bottomCellIdentifier];
        [self.contentView addSubview:self.tableView];
        
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return operationCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBookShelfBottomOperationTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:bottomCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBookShelfBottomOperationTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bottomCellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    cell.iconIV.image = [UIImage imageNamed:[self.imgsArray objectAtIndex:row]];
    cell.titleLab.text = [self.titleArray objectAtIndex:row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    
    if (self.clickBlock) {
        self.clickBlock(row);
    }
    
    [self startHide];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.anyObject;
    UIView* touchView = touch.view;
    if (touchView != self.contentView) {
        [self startHide];
    }
}

-(void)startHide {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect contentFrame = self.contentView.frame;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(0, screenSize.height, screenSize.width, contentFrame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate sendSystemNightShiftToback];
}

-(void)startShow {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat contentHeight = self.contentView.frame.size.height;
    CGRect finalFrame = CGRectMake(0, screenSize.height - contentHeight, screenSize.width, contentHeight);
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = finalFrame;
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
