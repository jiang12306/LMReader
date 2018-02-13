//
//  LMSpecialChoiceDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceDetailViewController.h"
#import "LMBaseBookTableViewCell.h"

@interface LMSpecialChoiceDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIImageView* headerIV;
@property (nonatomic, strong) UILabel* briefLab;//专题简介
@property (nonatomic, strong) UILabel* detailLab;//专题详情

@end

@implementation LMSpecialChoiceDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"专题详情";
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
    self.headerIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.headerView.frame.size.width - 10 * 2, 80)];
    self.headerIV.layer.cornerRadius = 5;
    self.headerIV.layer.masksToBounds = YES;
    self.headerIV.image = [UIImage imageNamed:@"test1"];
    [self.headerView addSubview:self.headerIV];
    
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.headerIV.frame.origin.y + self.headerIV.frame.size.height, self.headerIV.frame.size.width, 40)];
    self.briefLab.font = [UIFont systemFontOfSize:20];
    self.briefLab.text = @"专题介绍：风景ABCD";
    [self.headerView addSubview:self.briefLab];
    
    self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, self.briefLab.frame.size.width, 40)];
    self.detailLab.font = [UIFont systemFontOfSize:16];
    self.detailLab.text = @"刷卡机恩服务科技能分类矿务局来我家弄未开机放哪里金额 我就恩付款叫我呢文化分开就问你科技论文呢离开家我看见恩负看见我呢今晚很开放境内外肯健康稳健我";
    self.detailLab.numberOfLines = 0;
    self.detailLab.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.headerView addSubview:self.detailLab];
    
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 10 + self.headerIV.frame.size.height + self.briefLab.frame.size.height + self.detailLab.frame.size.height);
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.dataArray = [NSMutableArray array];
    [self.dataArray addObjectsFromArray:@[@"1", @"2", @"3", @"4", @"5", @"6"]];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.nameLab.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
