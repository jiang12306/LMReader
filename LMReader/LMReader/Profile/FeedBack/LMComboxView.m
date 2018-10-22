//
//  LMComboxView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMComboxView.h"
#import "LMComboxViewTableViewCell.h"

@interface LMComboxView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSArray* titleArr;
@property (nonatomic, strong) UIButton* selectedBtn;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) LMComboxViewBlock backBlock;

@end

@implementation LMComboxView

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype )initWithFrame:(CGRect )frame titleArr:(NSArray* )titleArr cellHeight:(CGFloat )cellHeight {
    self = [super initWithFrame:frame];
    if (self) {
        self.cellHeight = cellHeight;
        self.titleArr = [titleArr copy];
        self.backgroundColor = [UIColor clearColor];
        
        self.selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, cellHeight)];
        self.selectedBtn.backgroundColor = [UIColor whiteColor];
        self.selectedBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        self.selectedBtn.selected = NO;
        [self.selectedBtn setTitle:titleArr[0] forState:UIControlStateNormal];
        [self.selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.selectedBtn setImage:[UIImage imageNamed:@"comboxView_Down"] forState:UIControlStateNormal];
        [self.selectedBtn setImage:[UIImage imageNamed:@"comboxView_Up"] forState:UIControlStateSelected];
        [self.selectedBtn addTarget:self action:@selector(clickedSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.selectedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, frame.size.width - 115)];
        [self.selectedBtn setImageEdgeInsets:UIEdgeInsetsMake(8, frame.size.width - 20, 7, 5)];
        self.selectedBtn.layer.borderWidth = 1;
        self.selectedBtn.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
        [self addSubview:self.selectedBtn];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, cellHeight, frame.size.width, 0) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView registerClass:[LMComboxViewTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
    }
    return self;
}

-(void)clickedSelectButton:(UIButton* )sender {
    if (self.selectedBtn.selected == YES) {//收
        self.selectedBtn.selected = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.frame = CGRectMake(0, self.cellHeight, self.frame.size.width, 0);
        }];
    }else {//展
        self.selectedBtn.selected = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.frame = CGRectMake(0, self.cellHeight, self.frame.size.width, self.titleArr.count * self.cellHeight);
        }];
    }
}

-(void)didSelectedIndex:(LMComboxViewBlock)callBlock {
    self.backBlock = callBlock;
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
    
    for (NSInteger i = 0; i < self.titleArr.count; i ++) {
        NSIndexPath* tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        LMComboxViewTableViewCell* cell = [self.tableView cellForRowAtIndexPath:tempIndexPath];
        if (i == row) {
            cell.clicked = YES;
        }else {
            cell.clicked = NO;
        }
    }
    
    NSString* str = self.titleArr[row];
    [self.selectedBtn setTitle:str forState:UIControlStateNormal];
    
    self.selectedIndex = row;
    
    [self clickedSelectButton:self.selectedBtn];
    
    self.backBlock(self.selectedIndex);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
