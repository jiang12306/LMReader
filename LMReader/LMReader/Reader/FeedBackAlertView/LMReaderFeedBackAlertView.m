//
//  LMReaderFeedBackAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderFeedBackAlertView.h"
#import "LMReaderFeedBackAlertViewTableViewCell.h"


@implementation LMReaderFeedBackAlertViewModel


@end





@interface LMReaderFeedBackAlertView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIButton* submitBtn;

@end

@implementation LMReaderFeedBackAlertView

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        NSArray* tempArr = @[@"a.错字漏字", @"b.内容排版混乱", @"c.章节顺序错乱", @"d.章节缺少", @"e.更新延迟"];
        self.dataArray = [NSMutableArray array];
        for (NSString* subStr in tempArr) {
            LMReaderFeedBackAlertViewModel* model = [[LMReaderFeedBackAlertViewModel alloc]init];
            model.alertString = subStr;
            model.isSelected = NO;
            [self.dataArray addObject:model];
        }
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width - 100, screenRect.size.width)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 40 * self.dataArray.count) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[LMReaderFeedBackAlertViewTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self.contentView addSubview:self.tableView];
        
        self.submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, self.tableView.frame.origin.y + self.tableView.frame.size.height + 10, self.contentView.frame.size.width - 20, 30)];
        self.submitBtn.layer.cornerRadius = 5;
        self.submitBtn.layer.masksToBounds = YES;
        self.submitBtn.layer.borderColor = [UIColor blackColor].CGColor;
        self.submitBtn.layer.borderWidth = 1;
        [self.submitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.submitBtn setTitle:@"提 交" forState:UIControlStateNormal];
        [self.submitBtn addTarget:self action:@selector(clickedSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.submitBtn];
        
        self.contentView.frame = CGRectMake(0, 0, screenRect.size.width - 100, self.submitBtn.frame.origin.y + self.submitBtn.frame.size.height + 10);
        self.contentView.center = self.center;
    }
    return self;
}

-(void)clickedSubmitButton:(UIButton* )sender {
    if (self.submitBlock) {
        NSString* subStr = @"";
        for (LMReaderFeedBackAlertViewModel* model in self.dataArray) {
            if (model.isSelected) {
                subStr = [subStr stringByAppendingString:[NSString stringWithFormat:@",%@", model.alertString]];
            }
        }
        if (subStr.length > 0) {
            self.submitBlock(YES, subStr);
        }
    }
    
    [self startHide];
}

-(void)startShow {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)startHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    bool isContain = CGRectContainsPoint(self.contentView.frame, point);
    if (!isContain) {
        [self startHide];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMReaderFeedBackAlertViewTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMReaderFeedBackAlertViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    LMReaderFeedBackAlertViewModel* model = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLab.text = model.alertString;
    [cell setupClicked:model.isSelected];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LMReaderFeedBackAlertViewModel* model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.isSelected) {
        model.isSelected = NO;
    }else {
        model.isSelected = YES;
    }
    LMReaderFeedBackAlertViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setupClicked:model.isSelected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
