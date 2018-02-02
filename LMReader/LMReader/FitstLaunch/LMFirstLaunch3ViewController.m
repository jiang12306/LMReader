//
//  LMFirstLaunch3ViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFirstLaunch3ViewController.h"
#import "LMBaseBookTableViewCell.h"

@interface LMFirstLaunch3ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIButton* startBtn;

@end

@implementation LMFirstLaunch3ViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UILabel* headerLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerLab.text = @"我们为您准备好以下小说";
    headerLab.textAlignment = NSTextAlignmentCenter;
    headerLab.font = [UIFont systemFontOfSize:20];
    [headerView addSubview:headerLab];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.startBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    self.startBtn.backgroundColor = THEMECOLOR;
    [self.startBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
    self.startBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    self.startBtn.center = footerView.center;
    [self.startBtn addTarget:self action:@selector(clcikedStartButton:) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.layer.cornerRadius = 5;
    self.startBtn.layer.masksToBounds = YES;
    [footerView addSubview:self.startBtn];
    self.tableView.tableFooterView = footerView;
}

-(void)loadInterestData {
    self.dataArray = [NSMutableArray array];
    [self.dataArray addObjectsFromArray:@[@"1", @"2", @"3", @"4", @"5", @"6"]];
    [self.tableView reloadData];
}

-(void)clcikedStartButton:(UIButton* )sender {
    self.callBlock(YES);
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
